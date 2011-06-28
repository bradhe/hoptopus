Hoptopus::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[hoptopus.com] ",
  :sender_address => %{"The Hoptopus" <thehoptopus@hoptopus.com>},
  :exception_recipients => %w{brad.heller@hoptopus.com}
