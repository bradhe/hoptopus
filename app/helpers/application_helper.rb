require 'rubygems'
require 'maruku'

module ApplicationHelper
	def is_logged_in?
		not @user.nil?
	end
	
	def full_host
		host = self.request.host || "hoptopus.com"
		
		if (not self.request.port.nil?) and self.request.port != 80
			host += ':' + self.request.port.to_s
		end
		
		return host
	end
  
  def absolute_url(url)
    "http://#{full_host}#{url}"
  end
	
	def is_table_sortable?(collection) 
		if collection.nil?
			return nil
		end
		
		return collection.empty? ? "" : 'data-sortable="true"'
	end
  
  def m(str)
    str.blank? ? "" : Maruku.new(str).to_html
  end
  
  def render_event(event)
    if event.formatter
      event.formatter.render
    end
  end
end
