class UsersController < ApplicationController
  skip_before_filter :ensure_confirmed, :only => :send_confirmation
  
  def update
    @user = User.find params[:id]
    if(params[:user][:email].blank? and params[:user][:confirm].blank?)
      params[:user].delete :email
      params[:user].delete :email_confirmation
    end
    
    if params[:user][:state].nil?
      @user.state = nil
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

  def send_confirmation
    # Previous requests need to be set to expired.
    ConfirmationRequest.where(:user_id => @user.id).each { |c| c.expired = true; c.save }
    
    # Create a new one...
    confirmation_request = ConfirmationRequest.create :user => @user, :confirmation_code => Digest::SHA1.hexdigest(Time.now.to_s)
    Notifications.send_confirmation_request(confirmation_request).deliver

    redirect_to unconfirmed_path
  end
end
