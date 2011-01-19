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
		if request.post?
			@user = User.new(:username => params[:username], :email => params[:email], :password_hash => params[:password], :password_hash_confirmation => params[:password_confirmation])

			if @user.valid? and @user.save
				session[:user_id] = @user.id

				redirect_to root_path
			end
		end
	end
end
