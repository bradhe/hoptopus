class BeersController < ApplicationController
  before_filter :ensure_login, :except => [:index, :show]
  
  # GET /beers
  # GET /beers.xml
  def index
    @beers = Beer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @beers }
    end
  end
  
  def show
    @beer = Beer.find(params[:id])
    @revision = @beer.revisions.select { |r| r.revision == params[:r] } || @beer.current_revision
    @formatted_cellared_at = @beer.cellared_at ? @beer.cellared_at.strftime("%Y-%m-%d") : 'Unknown'
    @formatted_finish_aging_at = @beer.finish_aging_at ? @beer.finish_aging_at.strftime("%Y-%m-%d") : 'Unknown'
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @beers }
    end
  end

  # GET /beers/new
  # GET /beers/new.xml
  def new
    @beer = Beer.new

    if params[:beer]
      # Should look up by ID
      @beer.brew = Brew.find params[:beer]
    end

    # Some defaults for this new thing.
    @beer.cellared_at = Time.now
    @beer.quantity = 1

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @beer }
    end
  end

  # GET /beers/1/edit
  def edit
    @beer = Beer.find(params[:id])
    
    # Format the dates because fuck it sucks to do in views
    @formatted_finish_aging_at = @beer.finish_aging_at ? @beer.finish_aging_at.strftime("%Y-%m-%d") : ''
    @formatted_cellared_at = @beer.cellared_at ? @beer.cellared_at.strftime("%Y-%m-%d") : ''

    @years = (@beer.finish_aging_at.year - @beer.cellared_at.year) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
    @months = ((@beer.finish_aging_at.month - @beer.cellared_at.month) % 12) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
  end

  # POST /beers
  # POST /beers.xml
  def create
    # Figure out if the cellar ID is only numbers. if it is, it's an ID otherwise it's a username
    if params[:cellar_id].match /\d+/
      @cellar = Cellar.find params[:cellar_id]
    else
      @cellar = Cellar.find_by_username params[:cellar_id]
    end

    # This is kind of gross, but cleans up nicely.
    if params[:beer][:price] =~ /^\$/
      params[:beer][:price] = params[:beer][:price][1,(params[:beer][:price].length - 1)]
    end
    
    @beer = @cellar.beers.new(params[:beer])
    
    if @beer.valid?
      @beer.name = @beer.brew.name
      @beer.brewery_name = @beer.brew.brewery.name
    end
    
    return_to = @cellar.user == @user ? root_url : cellars_path(@cellar)
    
    respond_to do |format|
      if @beer.save
        # Record this momentous event.
        event = Event.new :user => @cellar.user, :source => @beer, :formatter => BeerAddedEventFormatter.new
        event.save
        
        # Now respond, boy!
        format.html { redirect_to(return_to, :notice => 'Beer was successfully created.') }
        format.xml  { render :xml => @beer, :status => :created, :location => @beer }
        format.json { render :json => @beer }
      else
        # Format the dates because fuck it sucks to do in views
        @formatted_finish_aging_at = @beer.finish_aging_at ? @beer.finish_aging_at.strftime("%Y-%m-%d") : ''
        @formatted_cellared_at = @beer.cellared_at ? @beer.cellared_at.strftime("%Y-%m-%d") : ''
			
        @years = (@beer.finish_aging_at.year - @beer.cellared_at.year) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
        @months = ((@beer.finish_aging_at.month - @beer.cellared_at.month) % 12) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
		
        format.html { render :action => "new" }
        format.xml  { render :xml => @beer.errors, :status => :unprocessable_entity }
        format.json { render :json => @beer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /beers/1
  # PUT /beers/1.xml
  def update
    cellar = Cellar.find(params[:cellar_id])
    
    # This is kind of gross, but cleans up nicely.
    if params[:beer][:price] =~ /^\$/
      params[:beer][:price] = params[:beer][:price][1,(params[:beer][:price].length - 1)]
    end
    
    @beer = Beer.find(params[:id])

    # We need to keep track of this for a bit...
    quantity = @beer.quantity
    
    respond_to do |format|
      if @beer.update_attributes(params[:beer])
        format.html { redirect_to(cellar_beer_path(cellar, @beer), :notice => "#{@beer.brew.name} has been updated!") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @beer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /beers/1
  # DELETE /beers/1.xml
  def destroy
    @beer = Beer.find(params[:id])
    
    # Beers don't get deleted, they just get removed from the cellar.
    @beer.removed_at = Time.now
    @beer.save

    respond_to do |format|
      format.html { redirect_to(cellar_path(@user.username)) }
      format.xml  { head :ok }
    end
  end
end
