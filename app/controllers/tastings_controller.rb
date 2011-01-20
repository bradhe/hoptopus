class TastingsController < ApplicationController
	def edit
		@tasting = Tasting.find(params[:id])
	end
	
	def show
		@tasting = Tasting.find(params[:id])
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
