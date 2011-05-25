# Load the rails application
require File.expand_path('../application', __FILE__)

#Rails.logger = Log4r::Logger.new "Hoptopus Log"

# Initialize the rails application
Hoptopus::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :user_name => 'thehoptopus@hoptopus.com',
  :password => '!!123abc',
  :authentication => :login,
  :enable_starttls_auto => true
}

Time::DATE_FORMATS.merge!(
  :default => lambda do |time|
    if time.today?
      # This is going to make baby jeebus cry.
      obj = Object.new
      obj.extend ActionView::Helpers::DateHelper

      # This...should...pass right through.
      obj.distance_of_time_in_words(time, Time.now)
    else
      # We want the "long" format
      time.strftime "%d %b %Y"
    end
  end
)
