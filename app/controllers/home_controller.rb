class HomeController < ApplicationController
	def index
		unless @user.nil?
			render 'logged_in'
		end
	end
end
