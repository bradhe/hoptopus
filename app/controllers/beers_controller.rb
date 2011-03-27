class BeersController < ApplicationController
  before_filter :ensure_login, :except => [:index, :show]
  before_filter :ensure_cellar

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

  def edit
    if request.post?
      unless params.has_key? :beer_id
        raise ArgumentError "Beer IDs are missing. You need to specify the IDs of beers you want to operate on."
      end

      @beers = params[:beer_id].map { |i| Beer.find i }

      respond_to do |format|
        format.html { render :partial => 'beers/multiedit' }
      end
    else
      @beer = Beer.find(params[:id])

      # Format the dates because fuck it sucks to do in views
      @formatted_finish_aging_at = @beer.finish_aging_at ? @beer.finish_aging_at.strftime("%Y-%m-%d") : ''
      @formatted_cellared_at = @beer.cellared_at ? @beer.cellared_at.strftime("%Y-%m-%d") : ''

      @years = (@beer.finish_aging_at.year - @beer.cellared_at.year) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
      @months = ((@beer.finish_aging_at.month - @beer.cellared_at.month) % 12) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
    end
  end

  def create
    # This is kind of gross, but cleans up nicely.
    if params[:beer][:price] =~ /^\$/
      params[:beer][:price] = params[:beer][:price][1,(params[:beer][:price].length - 1)]
    end

    # If a brew and brewery ID exist in the params then we should load it up
    if params[:beer].has_key? :brew_id and not params[:beer][:brew_id].blank?
      brew = Brew.find(params[:beer][:brew_id])
      params[:beer].delete(:brew_id)
    elsif params[:beer].has_key? :brew_id and params[:beer][:brew_id].blank?
      params[:beer].delete(:brew_id)
    end

    # We just need to ignore any brewery ids sent across for now. We get brewery from brew.
    params[:beer].delete(:brewery_id) if params[:beer].has_key? :brewery_id

    @beer = @cellar.beers.new(params[:beer])
    @beer.brew = brew unless brew.nil?
    
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

  def update
    if request.put?
      # UPDATE MULTIPLE BEERS
      unless params.has_key? :beer
        raise ArgumentError "Need a beers hash!"
      end
      
      beers = params[:beer].map { |k,v| Beer.find k }
      errors = beers.map { |b| {b.id => b.errors} unless b.update_attributes(params[:beer][b.id.to_s]) }

      # Remove any nil entries from errors. This occurs when there a save is successful.
      errors.delete_if { |i| i.nil? }
      
      respond_to do |format|
        if errors.empty?
          # No errors, hurray!
          format.json { render :nothing => true, :status => :ok }
        else
          format.json { render :json => { :errors => errors }, :status => :unprocessable_entity }
        end
      end
    else
      # UPDATE A SINGLE BEER
      
      # This is kind of gross, but cleans up nicely.
      if params[:beer][:price] =~ /^\$/
        params[:beer][:price] = params[:beer][:price][1,(params[:beer][:price].length - 1)]
      end
      
      @beer = Beer.find(params[:id])

      # We need to keep track of this for a bit...
      quantity = @beer.quantity
      
      respond_to do |format|
        if @beer.update_attributes(params[:beer])
          format.html { redirect_to(cellar_beer_path(@cellar, @beer), :notice => "#{@beer.brew.name} has been updated!") }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @beer.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @beer = Beer.find(params[:id])
    
    # Beers don't get deleted, they just get removed from the cellar.
    @beer.removed_at = Time.now
    @beer.save!

    respond_to do |format|
      format.html { redirect_to(cellar_path(@user.username)) }
      format.xml  { head :ok }
    end
  end
  
  private 
    def ensure_cellar
      unless params.has_key? :cellar_id
        raise ArgumentError "Cellar ID is missing from route."
      end
      
      cellar_id = params[:cellar_id]
      
      # We can pass either a cellar ID or a username. We really don't want
      # to pass a cellar ID, we prefer username.
      if cellar_id.class == Fixnum or cellar_id.match /^\d+$/
        @cellar = Cellar.find cellar_id
      else
        @cellar = Cellar.find_by_username cellar_id
      end
    end
end
