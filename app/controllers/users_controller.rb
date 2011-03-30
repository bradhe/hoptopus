class UsersController < ApplicationController
  skip_before_filter :ensure_confirmed, :only => [:send_confirmation, :confirm_email, :confirmation_sent]
  
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
    confirmation_request = ConfirmationRequest.create :user => @user
    Notifications.send_confirmation_request(confirmation_request).deliver

    redirect_to confirmation_sent_path
  end

  def confirm_email
    if confirmation = find_valid_confirmation(params[:confirmation_code])
      confirmation.update_attribute(:confirmed, true)

      # Save the user too
      @user.update_attribute(:confirmed, true)

      # Redirect to root.
      redirect_to root_url
    else
      render :template => 'users/invalid_confirmation_code'
    end
  end

  def confirmation_sent
  end

  private
  def find_valid_confirmation(confirmation_code)
    ConfirmationRequest.where(:confirmation_code => confirmation_code, :user_id => @user.id, :expired => false, :confirmed => false).first
  end
end
