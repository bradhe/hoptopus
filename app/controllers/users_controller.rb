class UsersController < ApplicationController
  skip_before_filter :ensure_confirmed, :only => [:send_confirmation, :confirm_email, :confirmation_sent]
  before_filter :require_authentication

  def update
    if(params[:user][:email].blank? and params[:user][:confirm].blank?)
      params[:user].delete(:email)
      params[:user].delete(:email_confirmation)
    end

    if params[:user][:state].nil?
      current_user.state = nil
    end

    respond_to do |format|
      # Copy the current user to avoid fucking something up
      @user = User.find(current_user.id)

      if @user.update_attributes(params[:user])
        format.html { redirect_to(preferences_user_path, :notice => 'Your preferences have been saved!') }
      else
        format.html { render :action => 'preferences' }
      end
    end
  end

  def preferences
    @user = current_user
  end

  def send_confirmation
    # Previous requests need to be set to expired.
    ConfirmationRequest.where(:user_id => current_user.id).each { |c| c.update_attribute(:expired, true) }

    # Create a new one...
    confirmation_request = ConfirmationRequest.create!(:user => current_user)
    Notifications.send_confirmation_request(confirmation_request).deliver

    redirect_to confirmation_sent_user_path
  end

  def confirm_email
    if confirmation = find_valid_confirmation(params[:confirmation_code])
      confirmation.update_attribute(:confirmed, true)

      # Save the user too
      current_user.update_attribute(:confirmed, true)

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
    ConfirmationRequest.where(:confirmation_code => confirmation_code, :user_id => current_user.id, :expired => false, :confirmed => false).first
  end
end
