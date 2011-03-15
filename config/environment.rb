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
