module Hoptopus
  module DateFormatters
    def format_date(time, format=:long)
      raise "Unsupported time object" unless time.respond_to? :today?

      if time.today?
        # This is going to make baby jeebus cry.
        obj = Object.new
        obj.extend ActionView::Helpers::DateHelper

        # This...should...pass right through.
        obj.distance_of_time_in_words(time, Time.now)
      else
        I18n.l(time, format)
      end
    end
  end
end
