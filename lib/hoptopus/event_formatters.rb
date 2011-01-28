module Hoptopus
	module EventFormatters
    class EventFormatterBase 
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      
      def css_class=(cls)
        @css_class = cls
      end
      
      def event=(event)
        @event = event
      end
      
      def event
        @event
      end
      
      def render
        content_tag 'li', format_message(event), {:class => @css_class}, false
      end
    end
    
    class BrewEditEventFormatter < EventFormatterBase
      def initialize
        @css_class = 'brew-edited'
      end
      
      def format_message(event)
        cellar_link = link_to event.user.username, app.cellar_path(event.user.username)
        brew_link = link_to event.source.name, app.brew_path(event.source)
        
        "#{cellar_link} edited #{brew_link} in the #{link_to 'Brew Wiki', app.brews_path}"
      end
    end
    #has_many :beer_added_events
  #has_many :brew_edited_events
 #has_many :brew_added_events
  #has_many :brew_tasted_events
  
    class BrewAddedEventFormatter < EventFormatterBase
      def initialize
        @css_class = 'brew-added'
      end
      
      def format_message(event)
        cellar_link = link_to event.user.username, app.cellar_path(event.user.username)
        brew_link = link_to event.source.name, app.brew_path(event.source)
        
        "#{cellar_link} added #{brew_link} to the #{link_to 'Brew Wiki', app.brews_path}"
      end
    end
    
    class BrewAddedEventFormatter < EventFormatterBase
      def initialize
        @css_class = 'brew-added'
      end
      
      def format_message(event)
        cellar_link = link_to event.user.username, app.cellar_path(event.user.username)
        brew_link = link_to event.source.name, app.brew_path(event.source)
        
        "#{cellar_link} added #{brew_link} to the #{link_to 'Brew Wiki', app.brews_path}"
      end
    end
    
    class BeerAddedEventFormatter < EventFormatterBase
      def initialize
        @css_class = 'beer-added'
      end
      
      def format_message(e)
        cellar_link = link_to e.user.username, app.cellar_path(e.user.username)
        beer_link = link_to (e.source.year ? e.source.year + ' ' : '') + e.source.name, app.cellar_beer_path(e.source.cellar, e.source)
        
        "#{cellar_link} added #{beer_link} to their #{link_to 'cellar', app.cellar_path(e.user.username)}"
      end
    end
    
    class BrewTastedEventFormatter < EventFormatterBase
      def initialize
        @css_class = 'brew-tasted'
      end
      
      def format_message(e)
        cellar_link = link_to e.user.username, app.cellar_path(e.user.username)
        brew_link = link_to e.source.brew.name, app.brew_tasting_path(e.source.brew, e.source)
        
        "#{cellar_link} added tasting notes for #{brew_link}"
      end
    end
	end
end