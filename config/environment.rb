# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
require 'sass/plugin'
Hoptopus::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :user_name => 'thehoptopus@hoptopus.com',
  :password => '!!123abc',
  :authentication => :login,
  :enable_starttls_auto => true
}
