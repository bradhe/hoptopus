class CellarsController < ApplicationController
  before_filter :ensure_login, :except => :show
  
  # GET /cellars
  # GET /cellars.xml
  def index
    @cellars = Cellar.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cellars }
    end
  end

  # GET /cellars/1
  # GET /cellars/1.xml
  def show
    @cellar = Cellar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cellar }
    end
  end
end
