require 'array'

class CellarsController < ApplicationController
  include UploadParsers
  
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
