Hoptopus::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_view.debug_rjs = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.default_url_options = { :host => "dev.hoptopus.com", :port => 3000 }
  
  # Determined that we don't actually want to do this yet...but someday we might!
  #config.action_controller.asset_host = "http://a.dev.hoptopus.com:3000"
end

