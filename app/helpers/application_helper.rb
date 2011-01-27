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
    li = '<li class="'
      
    if not event.beer_added_events.empty?
      msg = "<a href=\"/cellars/#{event.user.username}\">#{event.user.username}</a> added "
      
      beers = event.beer_added_events.map { |e| link_to (e.beer.year ? e.beer.year + ' ' : '') + e.beer.name, cellar_beer_path(e.beer.cellar, e.beer) }.join(', ')
      msg += "#{beers} to this cellar."
      
      li += "beer-added\">#{msg}"
    elsif not event.brew_edited_events.empty?
      brews = event.brew_edited_events.map { |e| link_to e.brew.name, brew_path(e.brew) }.join(', ')
      msg = "<a href=\"/cellars/#{event.user.username}\">#{event.user.username}</a> edited #{brews} in the #{ link_to 'Brew Wiki', brews_path }"
      
      li += "brew-edited\">#{msg}"
    elsif not event.brew_added_events.empty?
      brews = event.brew_added_events.map { |e| link_to e.brew.name, brew_path(e.brew) }.join(', ')
      msg = "<a href=\"/cellars/#{event.user.username}\">#{event.user.username}</a> added #{brews} to the #{ link_to 'Brew Wiki', brews_path }"
      
      li += "brew-added\">#{msg}"
    elsif not event.brew_tasted_events.empty?
      brews = event.brew_tasted_events.map { |e| link_to (e.year ? e.year.to_s + ' ' : '' ) + e.brew.name, brew_tasting_path(e.brew, e.tasting) }.join(', ')
      msg = "<a href=\"/cellars/#{event.user.username}\">#{event.user.username}</a> tasted #{brews}."
      
      li += "brew-tasted\">#{msg}"
    else
      li += 'empty">Something happened but not sure what...'
    end
    
    li += '<span class="timestamp note">(' + distance_of_time_in_words(event.created_at, Time.now) + ' ago)</span>'
    
    return li
  end
end
