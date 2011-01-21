class TastingsController < ApplicationController
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
    @tasting = Tasting.new(params[:tasting])
    
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
