class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    @user.email_consent = params[:user][:email_consent]
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to(root_url, :notice => 'Your preferences have been saved!') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tasting.errors, :status => :unprocessable_entity }
      end
    end
  end
end
