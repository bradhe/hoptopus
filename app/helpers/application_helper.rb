require 'rubygems'
require 'maruku'

module ApplicationHelper
  def is_logged_in?
    !!@user
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
  
  def gravatar_for(user, options = {})
    options = { :alt => 'avatar', :class => 'avatar' }.merge! options

    unless options.has_key?(:size) 
      options[:size] = 42
    end

    if user.facebook_id
      url = "http://graph.facebook.com/#{user.facebook_id}/picture"
      image_tag url, options
    elsif user.email
      id = Digest::MD5::hexdigest user.email.strip.downcase
      url = 'http://www.gravatar.com/avatar/' + id + '.jpg?r=pg&s=' + options[:size].to_s + '&d=' + CGI::escape(absolute_url "/images/hoptopus_avatar.png")
      options.delete :size
      image_tag url, options
    end
  end

  def alert(name, options = {}, &block)
    return if @user.nil?

    unless alert = @user.alerts.select{|a| a.name == name}.first
      alert = Alert.new(:name => name)
      @user.alerts << alert
      @user.save!
    end

    unless alert.dismissed
      options.merge!(:name => name)
      block_to_partial('shared/alert', options, &block)
    end
  end
end
