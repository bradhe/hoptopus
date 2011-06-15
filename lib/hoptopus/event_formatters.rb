module Hoptopus
	module EventFormatters
    class EventFormatterBase 
      include ActionView::Helpers::TagHelper

      def initialize(event)
        @event = event
      end

      def css_class=(cls)
        @css_class = cls
      end

      def event=(event)
        @event = event
      end

      def event
        @event
      end

      def event_time
        if @event.created_at > 1.days.ago
          @event.created_at.strftime '%I:%M:%S %p'
        else
          @event.created_at.strftime '%A %B %d, %Y'
        end
      end

      def render
        formatted_message = Maruku.new(format_message(event)).to_html + "<span class=\"timestamp note\">(#{event_time})</span>"
        content_tag 'li', formatted_message, {:class => @css_class}, false
      end
    end

    class BrewEditEventFormatter < EventFormatterBase
      def initialize(event)
        @css_class = 'brew-edited'
        super(event)
      end

      def format_message(event)
        username = event.user.username
        
        "[#{username}](/cellars/#{username}) edited [#{event.source.name}](/brews/#{event.source.id}) in the [Brew Wiki](/brews)"
      end
    end

    class BrewAddedEventFormatter < EventFormatterBase
      def initialize(event)
        @css_class = 'brew-added'
        super(event)
      end
      
      def format_message(event)
        username = event.user.username
        
        "[#{username}](/cellars/#{username}) added [#{event.source.name}](/brews/#{event.source.id}) to the [Brew Wiki](/brews)"
      end
    end

    class BeerAddedEventFormatter < EventFormatterBase
      def initialize(event)
        @css_class = 'beer-added'
        super(event)
      end
      
      def format_message(e)
        beer_link = "/cellars/#{e.user.username}/beers/#{e.source.id}"
        beer_name = (e.source.year ? e.source.year + ' ' : '') + e.source.name
        
        "[#{e.user.username}](/cellars/#{e.user.username}) added [#{beer_name}](#{beer_link}) to their [cellar](/cellars/#{e.user.username}#cellar)"
      end
    end
    
    class BeerTastedEventFormatter < EventFormatterBase
      def initialize(event)
        @css_class = 'brew-tasted'
        super(event)
      end
      
      def format_message(e)
        username = e.user.username
        
        "[#{username}](/cellars/#{username}) added tasting notes for [#{e.source.brew.name}](/brews/#{e.source.brew.id}/tastings/#{e.source.id})"
      end
    end
  end
end
