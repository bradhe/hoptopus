require 'rubygems'
require 'maruku'

module ApplicationHelper
	def is_logged_in?
		not @user.nil?
	end
  
  def location_str(params={})
    city = params[:city]
    state = params[:state]
    country = params[:country]

    if city and state and country
      location = city + ', ' + state + ' (' + country + ')'
    elsif city and state
      location = city + ', ' + state
    elsif city and country
      location = city + ' (' + country + ')'
    elsif state and country
      location = state + ' (' + country + ')'
    elsif city
      location = city
    elsif state
      location = state
    elsif country
      location = country
    else
      location = 'Unknown'
    end
    
    return location
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
  
  def format_date(date)
    if date.nil?
      return ''
    end
    
    date.strftime "%Y-%m-%d"
  end

  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    render(:partial => partial_name, :locals => options)
  end
  
  def gravatar_for user, options = {}
    if(user.respond_to? "email")
      options = { :default => '/images/little-hoptopus.png', :alt => 'avatar', :class => 'avatar', :size => 42 }.merge! options
      id = Digest::MD5::hexdigest user.email.strip.downcase
      url = 'http://www.gravatar.com/avatar/' + id + '.jpg?r=pg&s=' + options[:size].to_s + '&d=mm'
      options.delete :size
      image_tag url, options
    end
  end

  def alert(name, options = {}, &block)
    a = Alert.where('name = ? AND user_id = ?', name, @user.id).first

    if a.nil?
      a = Alert.create(:name => name, :user_id => @user.id)
    end

    unless a.dismissed
      options.merge!(:name => name)
      block_to_partial('shared/alert', options, &block)
    end
  end
end
