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

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @beers }
    end
  end

  # GET /beers/new
  # GET /beers/new.xml
  def new
    @beer = Beer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @beer }
    end
  end

  # GET /beers/1/edit
  def edit
    @beer = Beer.find(params[:id])
  end

  # POST /beers
  # POST /beers.xml
  def create
	@cellar = Cellar.find(params[:cellar_id])
	
	# This is kind of gross, but cleans up nicely.
	if params[:beer][:price] =~ /^\$/
		params[:beer][:price] = params[:beer][:price][1,(params[:beer][:price].length - 1)]
	end
	
  @beer = @cellar.beers.new(params[:beer])
  @beer.name = @beer.brew.name
  @beer.brewery_name = @beer.brew.brewery.name
	
	return_to = @cellar.user == @user ? root_url : cellars_path(@cellar)
	
    respond_to do |format|
      if @beer.valid? and @beer.save
        # Record this momentous event.
        event = Event.new :user => @cellar.user
        event.save
        
        beerAddedEvent = BeerAddedEvent.new :event => event, :beer => @beer
        beerAddedEvent.save

        # Now respond, boy!
        format.html { redirect_to(return_to, :notice => 'Beer was successfully created.') }
        format.xml  { render :xml => @beer, :status => :created, :location => @beer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @beer.errors, :status => :unprocessable_entity }
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
	
	return_to = cellar.user == @user ? root_url : cellars_path(cellar)
	
	# We need to keep track of this for a bit...
	quantity = @beer.quantity
	
    respond_to do |format|
      if @beer.update_attributes(params[:beer])
        format.html { redirect_to(return_to, :notice => "#{@beer.brew.name} has been updated!") }
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
    @beer.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.xml  { head :ok }
    end
  end
end
