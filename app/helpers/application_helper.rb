module ApplicationHelper
	def is_logged_in?
		not @user.nil?
	end
	
	def full_host
		host = self.request.host || "young-journey-427.heroku.com"
		
		if (not self.request.port.nil?) and self.request.port != 80
			host += ':' + self.request.port.to_s
		end
		
		return host
	end
	
	def is_table_sortable?(collection) 
		if collection.nil?
			return nil
		end
		
		return collection.empty? ? "" : 'data-sortable="true"'
	end
end
