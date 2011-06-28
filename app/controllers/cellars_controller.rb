require 'csv'
# Custom array shit
require 'array'

class CellarsController < ApplicationController
  include UploadParsers
  include AWS::S3

  def import_status
    @cellar = Cellar.find(params[:id])
    status = redis["cellar_import:#{@cellar.user_id}:status"].to_i

    if status == 2
      # Clean up after ourselves
      redis.del("cellar_import:#{@cellar.user_id}:status")
    elsif status == -1
      redis.del("cellar_import:#{@cellar.user_id}:status")
      redis.del("cellar_import:#{@cellar.user_id}:job_id")
    end

    respond_to do |format|
      format.json { render :json => { :status => status } }
    end
  end

  include ActionView::Helpers::TextHelper
  def import
    @cellar = Cellar.find_by_username(params[:id])

    # Did the give us a file?
    unless params[:import_file]
      render 'cellars/import/file_read_failed' and return
    end

    begin
      values = CSV.read(params[:import_file].tempfile.path)
    rescue => e
      render 'cellars/import/file_read_failed' and return
    end

    headers = values.shift
    if @invalid_columns = validate_import_columns(headers)
      @valid_columns = headers - @invalid_columns
      render 'cellars/import/invalid_columns' and return
    end

    # Otherwise, it looks good!
    headers = headers.map(&:downcase).map{ |h| h.gsub(/[\s\W]+/, '_').to_sym }

    success, failure, skipped = 0, 0, 0

    values.each do |beer|
      h = Hash[*headers.zip(beer).flatten]

      # We need to keep track of this...
      cellared_at = h.delete(:cellared_at) || ''

      # Make sure this doesn't explode...
      h[:name] ||= ''

      # Also try to parse a year if one can be done.
      if match = h[:name].strip.match(/^\d{4}|\d{4}$/)
        # In case we need to abort the process...
        original_name = h[:name]

        h[:name] = h[:name].strip.gsub(/[- ]*\d{4}$/, '').strip.gsub(/^\d{4}/, '').strip
        h[:year] = match[0].to_i

        # Make sure it falls within a valid range
        if h[:year] < 1970 or h[:year] > 2013
          h[:name] = original_name
          h.delete :year
        end
      end

      begin
        if @cellar.beers.exists?(h)
          skipped += 1
        else
          h[:cellared_at] = Time.parse(cellared_at)

          # Keep from creating events.
          h[:imported] = true

          @cellar.beers.create!(h)
          success += 1
        end
      rescue => e
        # Just log import failure
        failure += 1
      end
    end

    notice = ['Import successful!']
    notice << "#{pluralize(success, "beer")} imported." if(success > 0)
    notice << "#{pluralize(skipped, "beer")} skipped because they already exist or are duplicates." if(skipped > 0)
    notice << "Failed to import #{pluralize(failure, "beer")}" if(failure > 0)

    redirect_to cellar_path(@cellar), :notice => notice.join(' ')
  end

  # GET /cellars
  # GET /cellars.xml
  def index
    if current_user.nil? or current_user.should_show_own_events
      @recent_events = Event.order('created_at DESC').limit(15).all
    else 
      @recent_events = Event.order('created_at DESC').limit(15).where('user_id != ?', current_user.id).all
    end

    @newest_cellars = Cellar.newest.first(25).distribute(5)
    @largest_cellars = Cellar.largest.first(25).distribute(5)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cellars }
    end
  end

  def show
    if params[:id].nil?
      @cellar = Cellar.find_by_user(@user)
    else 
      user = User.find_by_username(params[:id])
      @cellar = Cellar.find_by_user(user)
    end

    # 404 if no user exists.
    render_404 and return if @cellar.nil?

    @tastings = @cellar.user.tasting_notes

    # This hash controls grid columns.
    @grid_columns = { 
      :formatted_cellared_at => { :id => 'created-at', :title => 'Cellared' },
      :brewery => { :id => 'brewery', :title => 'Brewery' },
      :name => { :id => 'variety', :title => 'Variety' },
      :year => { :id => 'year', :title => 'Year' },
      :quantity => { :id => 'quantity', :title => 'Quantity' },
      :formatted_price => { :id => 'price', :title => 'Price'},
      :bottle_size_name => { :id => 'bottle-size', :title => 'Bottle Size' },
      :style => { :id => 'style', :title => 'Style' }
    }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cellar }
    end
  end

  def validate_import_columns(headers)
    keys = headers.map(&:downcase).map{ |h| h.gsub(/[\s\W]+/, '_').to_sym }
    hash = Hash[*keys.zip(headers).flatten]

    invalid_columns = invalid_import_columns(hash.keys.map(&:to_s))

    # Sorry to anyone that sees this in the future
    return nil if invalid_columns.empty?
    invalid_columns.map { |key| hash[key.to_sym] }
  end

  def invalid_import_columns(cols)
    cols - Beer.importable_column_names
  end
end
