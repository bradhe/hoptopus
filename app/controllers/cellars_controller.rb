require 'array'

class CellarsController < ApplicationController
  include UploadParsers
  
  def confirm
    cellar = Cellar.find params[:id]
    uploaded_records = params[:records].map { |r| UploadedRecord.new(r[1]) }
    errors = []
    
    # Get all the breweries
    uploaded_records.each do |record|
      brewery = Brewery.find_or_create_by_name(record.brewery)
      brewery.save! unless brewery.persisted?
      
      brew_type = BrewType.find_or_create_by_name(record.brew_style)
      brew_type.save! unless brew_type.persisted?
      
      brew = brewery.brews.find_by_name(record.variety) || Brew.create(:name => record.variety, :brewery => brewery, :brew_type => brew_type)
      brew.save! unless brew.persisted?
      
      bottle_size = BottleSize.find_or_create_by_name(record.bottle_size)
      bottle_size.save! unless bottle_size.persisted?

      quantity = (record.quantity and record.quantity.to_i > 0) ? record.quantity.to_i : 1
      year = (record.year and record.year.match(/^\d{4}$/)) ? record.year.to_i : 2010
      cellared_at = (record.cellared_at.nil? or record.cellared_at.empty? ? DateTime.now : DateTime.parse(record.cellared_at))
      
      # Save the brew!
      beer = Beer.create :cellar => cellar, :brew => brew, :bottle_size => bottle_size, :year => year, :quantity => quantity, :cellared_at => cellared_at
      
      errors |= beer.errors.full_messages  
    end
    
    respond_to do |format|
      if errors.empty?
        format.html { redirect_to cellar_path cellar.user.username }
      else
        @upload_errors = errors
        format.html { render :template => 'cellars/upload_failed' }
      end
    end
  end
  
  def upload
    @cellar = Cellar.find params[:id]
    @cellar_upload = UploadCellar.new params[:upload_cellar]

    respond_to do |format|
      if @cellar_upload.valid?
        # Parse all this crap
        @uploaded_records = csv(@cellar_upload.file.tempfile.path)
        
        format.html { render :template => 'cellars/confirm_upload' }
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
      @tastings = @user.tastings
    else 
      user = User.find_by_username(params[:id])
      @cellar = Cellar.find_by_user(user)
      @tastings = @cellar.user.tastings
    end
    
    if @user == @cellar.user
      @new_beer = Beer.new
      
      if params[:beer]
        @new_beer.brew = Brew.find(params[:beer])
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cellar }
    end
  end
end
