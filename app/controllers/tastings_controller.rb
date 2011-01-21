class TastingsController < ApplicationController
  include ActionView::Helpers::DateHelper

	def edit
		@tasting = Tasting.find(params[:id])
	end

	def show
		@tasting = Tasting.find(params[:id])
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
	year = params[:tasting][:year]
	params[:tasting].delete(:year)
	
    @tasting = Tasting.new(params[:tasting])
	@tasting.save
	
	# Record this tasting event
	beer_name = (year + " " || "") + @tasting.brew.name
	aged = distance_of_time_in_words(@tasting.cellared_at, @tasting.created_at)
	tasting_path = brew_tasting_path(@tasting.brew, @tasting)
	brew_path = brew_path(@tasting.brew)
	
	event = Event.new :event_type => Event::TASTED, :user => @user
	event.text = "<a href=\"/cellars/#{@user.username}\">#{@user.username}</a> <a href=\"#{tasting_path}\">tasted</a> a <a href=\"#{brew_path}\">#{beer_name}</a> (aged #{aged})"
	event.save
	
    respond_to do |format|
      if @tasting.save
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
