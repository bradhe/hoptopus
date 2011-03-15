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

  def select_username
    @new_user = User.new
    @email_address = session[:registration][:email]
    
    # Configure this in case we have matched an email address.
    if session.has_key?(:registration) and session[:registration].has_key?(:user_id)
      @matched_user = User.find(session[:registration][:user_id])
    end
  end

  def update_username
    @new_user = User.new :email => session[:registration][:email], :username => params[:user][:username], :facebook_id => session[:registration][:facebook_id]

    respond_to do |format|
      if @new_user.valid?
        # We got three of them! Sweet!
        @new_user.save!
        Notifications.user_registered(@new_user).deliver

        Cellar.create :user => @new_user
        
        # Also clean up their session.
        session.delete :registration
        
        # Finally, log in the guy.
        login_user @new_user

        format.html { redirect_to root_path }
      else
        # Clear this to prevent some strange behavior.
        @new_user.username = nil

        # fml
        format.html { render :action => 'select_username' }
      end
    end
  end
end
