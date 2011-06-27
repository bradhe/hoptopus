class BeersController < ApplicationController
  before_filter :require_authentication, :except => [:show]
  before_filter :load_cellar

  def show
    @beer = @cellar.beers.find(params[:id])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @beer }
    end
  end

  def new
    @beer = @cellar.beers.new

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
      unless params.has_key? :selected_beers
        raise ArgumentError, "Beer IDs are missing. You need to specify the IDs of beers you want to operate on."
      end

      @beers = params[:selected_beers].map { |i| Beer.find(i) }

      respond_to do |format|
        format.html { render :partial => 'beers/multiedit' }
      end
    else
      @beer = @cellar.beers.find(params[:id])
      @years = (@beer.finish_aging_at.year - @beer.cellared_at.year) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
      @months = ((@beer.finish_aging_at.month - @beer.cellared_at.month) % 12) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
    end
  end

  def create
    # This is kind of gross, but cleans up nicely.
    params[:beer][:price] = params[:beer][:price][1,(params[:beer][:price].length - 1)] if params[:beer][:price] =~ /^\$/

    tasting_note_hash = params[:beer].delete(:tasting_note) || {}
    @beer = @cellar.beers.create(params[:beer])

    respond_to do |format|
      if @beer.valid?
        # Create a new tasting note if one was given.
        # Clean out all the empty tasting note fields.
        tasting_note_hash = tasting_note_hash.reject { |k,v| v.empty? }
        @beer.tasting_notes.create!(tasting_note_hash) unless tasting_note_hash.empty?

        # Now respond, boy!
        format.html { redirect_to(cellar_path(@cellar), :notice => 'Beer was successfully created.') }
        format.json { render :json => @beer }
      else
        # Format the dates because fuck it sucks to do in views
        @years = (@beer.finish_aging_at.year - @beer.cellared_at.year) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?
        @months = ((@beer.finish_aging_at.month - @beer.cellared_at.month) % 12) unless @beer.cellared_at.nil? or @beer.finish_aging_at.nil?

        format.html { render :action => "new" }
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

      # Also, errors need to be hashes and not an array
      errors_copy = {}

      errors.each do |a|
        errors_copy[a.keys[0]] = a[a.keys[0]]
      end

      errors = errors_copy

      respond_to do |format|
        if errors.empty?
          # No errors, hurray! We have to render SOMETHING tho or else jQuery gets all pissy.
          format.json { render :json => {:success => true}, :status => :ok }
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
    if params[:remove]
      @removed_beers = params[:remove].map { |i| @cellar.beers.find(i) }
      @removed_beers.each do |b|
        b.update_attribute(:removed_at, Time.now)
      end

      @beer_ids = @removed_beers.map(&:id)
    end

    if params[:destroy]
      @deleted_beers = params[:destroy].map { |i| @cellar.beers.find(i) }
      @beer_ids ||= []
      @beer_ids = @beer_ids.push(@deleted_beers.map(&:id)).flatten
      @deleted_beers.map { |b| b.destroy }
    end

    respond_to do |format|
      format.json { render :json => @beer_ids }
    end
  end

  private 
  def load_cellar
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
