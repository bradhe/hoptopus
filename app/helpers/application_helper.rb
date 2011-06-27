require 'rubygems'
require 'maruku'

module ApplicationHelper
  include Hoptopus::DateFormatters

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
    return nil if collection.nil? or collection.empty?
    'data-sortable="true"'
  end

  def m(str)
    str.blank? ? "" : Maruku.new(str).to_html
  end

  def render_event(event)
    event.formatter.render if event.formatter
  end

  def format_date(date)
    return '' if date.nil?
    date.strftime "%Y-%m-%d"
  end

  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    render(:partial => partial_name, :locals => options)
  end

  def gravatar_for(user, options = {})
    options = { :alt => 'avatar', :class => 'avatar' }.merge! options

    if user.facebook_id
      #TODO: Remove duplicate code...removing it breaks some shit.
      url = "http://graph.facebook.com/#{user.facebook_id}/picture"
      image_tag url, options
    elsif user.email
      id = Digest::MD5::hexdigest user.email.strip.downcase
      url = 'http://www.gravatar.com/avatar/' + id + '.jpg?r=pg&s=' + options[:size].to_s + '&d=' + CGI::escape(absolute_url "/images/hoptopus_avatar.png")
      options.delete :size
      image_tag url, options
    end
  end

  def facebook_avatar(facebook_id, options={})
    default_options = { 
      :class => 'facebook'
    }

    url = "http://graph.facebook.com/#{facebook_id}/picture"
    image_tag url, options.merge(default_options)
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

  def beer_title(beer)
    "#{beer.year} #{beer.name}".strip
  end

  def date(d)
    d ? d.strftime("%Y-%m-%d") : nil
  end

  def user_owns_cellar?(cellar)
    return false unless current_user
    cellar == current_user.cellar
  end
end
