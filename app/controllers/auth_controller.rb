class AuthController < ApplicationController
	def login
	  @user = User.authenticate_without_password_hash(params[:username], params[:password])

	  unless @user.nil?
	    session[:user_id] = @user.id
	    redirect_to root_path
	  end
	end
	
	def logout
	  session[:user_id] = nil
	  redirect_to root_path
	end
	
	def register
    @new_user = User.new 
    
		if request.post?
			@new_user = User.new(params[:user])

			if @new_user.valid? and @new_user.save
				session[:user_id] = @new_user.id
				
				# Also create a cellar for this user.
				cellar = Cellar.new(:user => @new_user)
				cellar.save

				redirect_to root_path
			end
		end
	end
  
  def reset_password
    if request.post? and params[:id] 
      # This is a post back with a thinger. Lets set the password for this guys.
    elsif request.post? 
      requested_user = User.find_by_username(params[:request][:username])
      
      request = PasswordResetAttempt.new :user => requested_user
      request.save
      
      # Update the security token with the created_time
      request.security_token = Digest::SHA1.hexdigest(request_user + ' - ' + request.created_at)
      request.save # Save once more...
      
      # Send out the email and show the "it's on its way" email.
      # TODO: Implement that here
    elsif params[:id] 
      # Make sure we're within the bounds of the request. If it's older than two days
      # then we need to have them make another request.
      @reset_request = PasswordResetAttempt.find_by_security_token(params[:id])
      
      # They have a two-day window to reclaim their thing.
      if @reset_request.created_at < (Time.now - 2.days)
        # TODO: Figure out what tod ohere
        redirect_to reset_password_path, :notice => 'Your shit falls outside the bounds of the real world. Please check yourself.'
      end

      # Show the form that allows the password to be reset
    else
      # just display like normal
      @reset_request = PasswordResetAttempt.new
      
    end
  end
end
