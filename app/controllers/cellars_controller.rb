require 'array'

class CellarsController < ApplicationController
  include UploadParsers
  include AWS::S3
  
  before_filter do
    if params.has_key?(:id) and params[:id].end_with? '.js'
      params[:id] = params[:id][0..-4] 
      request.format = :js
    end
  end

  def import_status
    @cellar = Cellar.find params[:id]
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

  def import_failed
  end

  def confirm_import
    # We need to get all the records by job ID
    @cellar = Cellar.find params[:id]
    job_id = redis["cellar_import:#{@cellar.user_id}:job_id"]

    if request.post? and not params[:done]
      # Update the posted records
      records = params[:records].map do |r| 
        attributes = r[1]
        record = UploadedBeerRecord.find(attributes[:id])

        # Delete ID for now
        attributes.delete(:id)
        record.update_attributes(attributes)
      end
    elsif request.post? and params[:done]
      # We're done so we need to schedule this job for import
      # and show the next interstitial
      Resque.enqueue(ProcessConfirmedImport, job_id, @cellar.user_id)

      respond_to do |format|
        format.html { render :template => 'cellars/processing' }
      end

      # Get outta here
      return
    end

    @uploaded_records = UploadedBeerRecord.where(:job_id => job_id).order('brewery').all

    unless params[:p].nil?
      p = params[:p].to_i
      all_records = UploadedBeerRecord.where(:job_id => job_id).order('brewery').all      
      @uploaded_records = all_records[p, 25]
      @total_records = all_records.count
    else
      @uploaded_records = UploadedBeerRecord.where(:job_id => job_id).order('brewery').first(25)
      @total_records = UploadedBeerRecord.where(:job_id => job_id).count
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  def import_confirmed
    cellar = Cellar.find params[:id]
    uploaded_records = params[:records].map { |r| UploadedRecord.new(r[1]) }
    errors = []
    
    # Get all the breweries
    Thread.new do
      process_upload uploaded_records
    end
    
    respond_to do |format|
      format.html { redirect_to cellar_path cellar.user.username }
    end
  end
  
  def upload
    @cellar = Cellar.find params[:id]
    @cellar_upload = UploadCellar.new params[:upload_cellar]

    respond_to do |format|
      if @cellar_upload.valid?
        # Parse all this crap
        file_name = File.basename(@cellar_upload.file.tempfile.path)
        S3Object.store file_name, @cellar_upload.file.tempfile, 'hoptopus'

        # Fire the job.
        Resque.enqueue(ImportCellar, file_name, @cellar.user_id)

        # Mark cellar as "importing"
        redis["cellar_import:#{@cellar.user_id}:status"] = 0
        
        format.html { render :template => 'cellars/importing' }
      else
        format.html # upload.html.erb
      end
    end
  end
  
  # GET /cellars
  # GET /cellars.xml
  def index
    if @user.nil? or @user.should_show_own_events
      @recent_events = Event.order('created_at DESC').limit(15).all
    else 
      @recent_events = Event.order('created_at DESC').limit(15).where("user_id != #{@user.id}").all
    end

    @newest_cellars = Cellar.order('created_at DESC').limit(25).all.distribute 5
    @largest_cellars = Cellar.all.sort!{ |a,b| b.beers.count <=> a.beers.count }.first(25).distribute 5

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cellars }
    end
  end

  def show
    if params[:id].nil?
      @cellar = Cellar.find_by_user(@user)
      @tastings = @user.tasting_notes
    else 
      user = User.find_by_username(params[:id])
      @cellar = Cellar.find_by_user(user)
      @tastings = @cellar.user.tasting_notes
    end

    @cellared_beers = @cellar.beers.select { |b| b.removed_at.nil? }.first(25)
    @beers_left_in_pagination = @cellar.beers.count - 25
    
    # This hash controls grid columns.
    @grid_columns = { 
      :formatted_cellared_at => { :id => 'created-at', :title => 'Cellared' },
      :brewery_name => { :id => 'brewery', :title => 'Brewery' },
      :name => { :id => 'variety', :title => 'Variety' },
      :year => { :id => 'year', :title => 'Year' },
      :quantity => { :id => 'quantity', :title => 'Quantity' },
      :formatted_price => { :id => 'price', :title => 'Price'},
      :bottle_size_name => { :id => 'bottle-size', :title => 'Bottle Size' }
    }

    respond_to do |format|
      format.html # show.html.erb
      format.js # show.js.erb
      format.xml  { render :xml => @cellar }
    end
  end
end
