class UsersController < ApplicationController
  def update
    @user = User.find params[:id]
    
    if params[:user][:state].nil?
      @user.state = nil
    end
    
    email = params[:user][:email]
    existing = User.find_by_email email
    
    # It could be the case that the person tried to log in with their FB Connect account
    # before but failed.
    if existing and existing.facebook_id and not existing.username
      # Delete the facebook connect record for this
      existing.destroy 
    end
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(cellar_path(@user.username), :notice => 'Your preferences have been saved!') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tasting.errors, :status => :unprocessable_entity }
      end
    end
  end
end
