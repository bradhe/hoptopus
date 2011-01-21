class BeersController < ApplicationController
  include ActionView::Helpers::DateHelper
  before_filter :ensure_login, :except => :index
  
  # GET /beers
  # GET /beers.xml
  def index
    @beers = Beer.all

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
	cellar = Cellar.find(params[:cellar_id])
    @beer = cellar.beers.new(params[:beer])
	
	# Record this momentous event.
	beer_name = (@beer.year ? @beer.year + " " : "") + @beer.brew.name
	username = cellar.user.username
	
	event = Event.new :user => cellar.user, :event_type => Event::UPDATED_CELLAR
	event.text = "#{username} added <a href=\"/brews/#{@beer.brew.id}\">#{beer_name}</a> to <a href=\"/cellars/#{username}\">their cellar</a>"
	event.save
	
	return_to = cellar.user == @user ? root_url : cellars_path(cellar)
	
    respond_to do |format|
      if @beer.save
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
    @beer = Beer.find(params[:id])
	
	return_to = cellar.user == @user ? root_url : cellars_path(cellar)
	
	# We need to keep track of this for a bit...
	quantity = @beer.quantity
	
    respond_to do |format|
      if @beer.update_attributes(params[:beer])
	    # Check the quantity -- if it's changing we need to create a tasting record.
		if quantity != @beer.quantity
			tasting = Tasting.new :user => @user, :beer => @beer
			tasting.save
			
			# Record this tasting event
			beer_name = (@beer.year ? @beer.year + " " : "") + @beer.brew.name
			aged = distance_of_time_in_words(@beer.cellared_at, tasting.created_at)
			
			event = Event.new :event_type => Event::TASTED, :user => @user
			event.text = "<a href=\"/cellars/#{@user.username}\">#{@user.username}</a> <a href=\"#{brew_tasting_path(tasting)}\">tasted</a> a <a href=\"#{brew_path(@beer.brew)}\">#{beer_name}</a> (aged #{aged})"
			event.save
			
			update_type = 'Tasting has been recorded! Add notes below.'
		else 
			update_type = 'Beer was successfully updated.'
		end
		
        format.html { redirect_to(return_to, :notice => update_type) }
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
      format.html { redirect_to(beers_url) }
      format.xml  { head :ok }
    end
  end
end
