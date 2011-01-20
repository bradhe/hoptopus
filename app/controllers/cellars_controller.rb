class CellarsController < ApplicationController
  before_filter :ensure_login, :except => :show
  
  # GET /cellars
  # GET /cellars.xml
  def index
	@recent_events = Event.find(:all, :conditions => "event_type='#{Event::UPDATED_CELLAR}' OR event_type='#{Event::TASTED}'", :order => 'created_at DESC', :limit => 15)
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cellar }
    end
  end
end
