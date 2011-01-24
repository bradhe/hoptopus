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
end
