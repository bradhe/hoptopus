class BrewsController < ApplicationController
  before_filter :ensure_login, :except => [:index, :show]
  
  # GET /brews
  # GET /brews.xml
  def index
    @brews = Brew.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @brews }
    end
  end

  # GET /brews/1
  # GET /brews/1.xml
  def show
    @brew = Brew.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @brew }
    end
  end

  # GET /brews/new
  # GET /brews/new.xml
  def new
    @brew = Brew.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @brew }
    end
  end

  # GET /brews/1/edit
  def edit
    @brew = Brew.find(params[:id])
  end

  # POST /brews
  # POST /brews.xml
  def create
    @brew = Brew.new(params[:brew])

    respond_to do |format|
      if @brew.save
        format.html { redirect_to(brews_url, :notice => 'Brew was successfully created.') }
        format.xml  { render :xml => @brew, :status => :created, :location => @brew }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @brew.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /brews/1
  # PUT /brews/1.xml
  def update
    @brew = Brew.find(params[:id])

    respond_to do |format|
      if @brew.update_attributes(params[:brew])
        format.html { redirect_to(brews_url, :notice => 'Brew was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @brew.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /brews/1
  # DELETE /brews/1.xml
  def destroy
    @brew = Brew.find(params[:id])
    @brew.destroy

    respond_to do |format|
      format.html { redirect_to(brews_url) }
      format.xml  { head :ok }
    end
  end
end