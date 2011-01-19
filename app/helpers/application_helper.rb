module ApplicationHelper
	def is_logged_in?
		not @user.nil?
	end
end
