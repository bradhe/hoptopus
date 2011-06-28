module Hoptopus
  module DateFormatters
    include ActionView::Helpers::DateHelper

    def format_date(time, format=:long)
      raise "Unsupported time object" unless time.respond_to? :today?

      if time.today?
        # This...should...pass right through.
        distance_of_time_in_words(time, Time.now) + (time < Time.now ? ' ago' : '')
      else
        I18n.l(time, :format => format)
      end
    end
  end
end
