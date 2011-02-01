class TastingsController < ApplicationController
  include ActionView::Helpers::DateHelper

	def edit
		@tasting = Tasting.find(params[:id])
	end

	def show
		@tasting = Tasting.find(params[:id])
	end
  
  def new
    @beer = Beer.find(params[:beer_id])
    @tasting = Tasting.new :brew => @beer.brew, :cellared_at => @beer.cellared_at
  end

	def destroy
		@tasting = Tasting.find(params[:id])
		@tasting.destroy
		
		respond_to do |format|
			format.html { redirect_to(root_url) }
			format.xml  { head :ok }
		end
	end
	  
  def create
    @beer = Beer.find(params[:beer_id])
    
    @tasting = Tasting.new(params[:tasting])
    @tasting.cellared_at = @beer.cellared_at
    @tasting.brew = @beer.brew
    @tasting.user = @user
    @tasting.save
    
    # Record this tasting event
    event = Event.new :user => @user, :source => @tasting, :formatter => BrewTastedEventFormatter.new
    event.save
      
    respond_to do |format|
      if @tasting.save
        format.html { redirect_to(brew_tasting_path(@tasting.brew, @tasting)) }
        format.json { render :json => @tasting.to_json }
      else
        format.json { render :json => { :status => :error, :message => "Could not create new tasting" }.to_json, :status => 400 }
      end
    end
  end
	
  def update
    @tasting = Tasting.find(params[:id])

    respond_to do |format|
      if @tasting.update_attributes(params[:tasting])
        format.html { redirect_to(root_url, :notice => 'Tasting notes were saved!') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tasting.errors, :status => :unprocessable_entity }
      end
    end
  end
end
