class CellarsController < ApplicationController
  def upload
    @cellar = Cellar.find params[:cellar_id]
    @cellar_upload = UploadCellar.new params[:upload_cellar]
    
    respond_to do |format|
      if @celar_upload.valid?
      
      else
        format.html # index.html.erb
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
    
    @cellars = Cellar.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cellars }
    end
  end

  # GET /cellars/1
  # GET /cellars/1.xml
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
