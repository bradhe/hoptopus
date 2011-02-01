class BrewsController < ApplicationController
  before_filter :ensure_login, :except => [:index, :show]
  
  # GET /brews
  # GET /brews.xml
  def index
    @brews = Brew.order('name').all
    @recent_events = Event.where('source_type = ? OR source_type = ?', 'Brew', 'Tasting').order('created_at DESC').all
    @breweries = Brewery.order('name').all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @brews }
    end
  end

  # GET /brews/1
  # GET /brews/1.xml
  def show
    @brew = Brew.find(params[:id])
    
    if params[:r]
      @revision = @brew.revisions.where(:revision => params[:r]).first
      
      unless @revision
        raise ActiveRecord::RecordNotFound, "Unable to find revision #{params[:r]}"
      end
    else
      @revision = @brew.current_revision || Wiki.new
    end
    
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
    @brew.markup ||= Brew.wiki_template
  end

  # POST /brews
  # POST /brews.xml
  def create
    @brew = Brew.new(params[:brew])

    respond_to do |format|
      if @brew.save
        # Record this momentous event.
        last_event = Event.order('created_at').where('formatter_type = ? AND user_id = ? AND source_id = ?', 'BrewAddedEventFormatter', @user.id, @brew.id).first
        
        if last_event and last_event.created_at > 1.days.ago
          event = Event.new :user => @user, :source => @brew, :formatter => BrewAddedEventFormatter.new
          event.save
        end
        
        format.html { redirect_to(edit_brew_path(@brew), :notice => 'Brew was successfully created.') }
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
        # Record this momentous event.
        last_event = Event.order('created_at').where('formatter_type = ? AND user_id = ? AND source_id = ?', 'BrewEditEventFormatter', @user.id, @brew.id).first
        
        if last_event and last_event.created_at > 1.days.ago
          event = Event.new :user => @user, :source => @brew, :formatter => BrewEditEventFormatter.new
          event.save
        end
        
        format.html { redirect_to(@brew, :notice => 'Brew was successfully updated.') }
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

    respond_to do |format|
      if not @brew.beers.empty? or not @brew.tastings.empty?
        format.html { redirect_to(brews_url, :notice => "Brew cannot be deleted. #{@brew.beers.count} cellared beers and #{@brew.tastings.count} tastings associated with this brew still.") }
        format.xml  { head :ok }
      else 
        @brew.destroy
        format.html { redirect_to(brews_url) }
        format.xml  { head :ok }
      end
    end
  end
end
