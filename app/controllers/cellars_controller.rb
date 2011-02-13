require 'array'

class CellarsController < ApplicationController
  include UploadParsers

  def import_status
    @cellar = Cellar.find params[:id]
    status = redis["cellar_import:#{@cellar.user_id}:status"].to_i

    if status == 2
      # Clean up after ourselves
      redis.del("cellar_import:#{@cellar.user_id}:status")
    end

    respond_to do |format|
      format.json { render :json => { :status => status } }
    end
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
        path = File.join(Rails.root, 'tmp', file_name)
        path = "#{path}_#{Process.pid}"

        File.open(path, 'wb') { |f| f.write(@cellar_upload.file.read) }

        # Fire the job.
        Resque.enqueue(ImportCellar, path, @cellar.user_id)

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
  
  def process_upload(uploaded_records) 

  end
end
