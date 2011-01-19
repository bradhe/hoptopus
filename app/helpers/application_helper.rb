module ApplicationHelper
	def is_logged_in?
		not @user.nil?
	end
	
	def full_host
		host = self.request.host
		
		if self.request.port != 80
			host += ':' + self.request.port.to_s
		end
	end
end
