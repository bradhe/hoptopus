class AuthController < ApplicationController
  # TODO: Remove this, we shouldn't mix this stuff in.
  include ApplicationHelper

  skip_before_filter :ensure_confirmed
  before_filter :require_authentication, :only => [:unconfirmed]
  
  def login
    if request.post?
      @user = User.authenticate_without_password_hash(params[:email], params[:password])
    end

    unless @user.nil?
      login_user @user
      redirect_to(session.delete(:redirected_from) || cellar_path(@user))
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end

  def register
    @new_user = User.new 

    if request.post?
      # Use short validation from now on.
      params[:user][:use_short_validation] = true
      @new_user = User.create(params[:user])

      if @new_user.valid?
        login_user @new_user

        # Alert that there was a registration
        Notifications.user_registered(@new_user).deliver

        redirect_to cellar_path(@new_user)
      end
    end
  end

  def request_password_reset
    if request.post? 
      @reset_request = PasswordResetAttempt.new(params[:password_reset_attempt])
      
      if @reset_request.valid?
        user = User.find_by_email(@reset_request.user_email)
        
        # Update the security token with the created_time
        @reset_request.security_token = Digest::SHA1.hexdigest(Time.now.to_s)
        @reset_request.user = user
        
        if @reset_request.save 
          # Send out the email and show the "it's on its way" email.
          PasswordReset.reset_mail(user, @reset_request.security_token, full_host).deliver
          
          # Delete all the other attempts
          PasswordResetAttempt.where("user_id='#{@reset_request.user.id}'").all.each do |p|
            unless p == @reset_request
              p.delete
            end
          end
          
          # TODO: Implement that here
          redirect_to password_reset_confirmation_sent_path
        end
      end
    else
      # just display like normal
      @reset_request = PasswordResetAttempt.new
    end
  end
  
  def confirm_password_reset
    if request.put?
      # This is a post back with a thinger. Lets set the password for this guys.
      @reset_request = PasswordResetAttempt.find_by_security_token(params[:id])

      if (@reset_request and @reset_request.created_at < (Time.now - 2.days)) or @reset_request.confirmed
        # TODO: Figure out what to do here
        redirect_to request_password_reset_path, :notice => 'The security token you supplied is invalid or out of date. Please re-request a password reset if you still need one.'
      end

      if @reset_request.update_attributes(params[:password_reset_attempt])
        @reset_request.user.password_hash = Digest::SHA256.hexdigest(@reset_request.password)
        @reset_request.user.save
      
        # Login this user
        login_user @reset_request.user
        
        # Also set the request to confirmed.
        @reset_request.confirmed = true
        @reset_request.save
      
        redirect_to root_path
      end      
    else
      # Make sure we're within the bounds of the request. If it's older than two days
      # then we need to have them make another request.
      @reset_request = PasswordResetAttempt.find_by_security_token(params[:id])
        
      # They have a two-day window to reclaim their thing.
      if not @reset_request or (@reset_request.created_at < (Time.now - 2.days)) or @reset_request.confirmed
        # TODO: Figure out what to do here
        redirect_to request_password_reset_path, :notice => 'The security token you supplied is invalid or out of date. Please re-request a password reset if you still need one.'
      end

      # Show the form that takes a password and a confirmed password.
    end
  end

  def password_reset_confirmation_sent
  end

  def unconfirmed
  end
end 
