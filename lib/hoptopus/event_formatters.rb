module Hoptopus
  module EventFormatters
    class EventFormatterBase 
      include ActionView::Helpers::TagHelper
      include Hoptopus::DateFormatters

      def initialize(event)
        @event = event
      end

      def event=(event)
        @event = event
      end

      def event
        @event
      end

      def event_time
        format_date(@event.created_at)
      end

      def render
        formatted_message = Maruku.new(format_message(event)).to_html + "<span class=\"timestamp note\">(#{event_time})</span>"
        content_tag 'li', formatted_message, {:class => css_class}, false
      end
    end

    class BeerAddedEventFormatter < EventFormatterBase
      def format_message(e)
        beer_link = "/cellars/#{e.user.username}/beers/#{e.source.id}"
        beer_name = (e.source.year ? e.source.year + ' ' : '') + e.source.name

        "[#{e.user.username}](/cellars/#{e.user.username}) added [#{beer_name}](#{beer_link}) to their [cellar](/cellars/#{e.user.username}#cellar)"
      end

      def css_class
        'beer-added'
      end
    end

    class BeerTastedEventFormatter < EventFormatterBase
      def css_class
        'brew-tasted'
      end

      def format_message(e)
        username = e.user.username
        beer_name = (e.source.beer.year ? e.source.beer.year + ' ' : '') + e.source.beer.name

        "[#{username}](/cellars/#{username}) added tasting notes for [#{beer_name}](/cellars/#{e.user.username}/beers/#{e.source.beer.id})"
      end
    end

    class WatchedEventFormatter < EventFormatterBase
      def css_class
        'watched'
      end

      def format_message(e)
        username = e.user.username
        watched_username = e.source.username

        "[#{username}](/cellars/#{username}) started watching [#{watched_username}](/cellars/#{watched_username})"
      end
    end

    class BeerRemovedEventFormatter < EventFormatterBase
      def css_class
        'beer-removed'
      end

      def format_message(e)
        username = e.user.username
        beer_name = (e.source.year ? e.source.year + ' ' : '') + e.source.name

        "[#{username}](/cellars/#{username}) removed [#{beer_name}](/cellars/#{e.user.username}/beers/#{e.source.id}) from their cellar"
      end
    end
  end
end
