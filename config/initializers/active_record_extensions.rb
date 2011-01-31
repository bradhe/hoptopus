ActiveRecord::Base.send :include, Hoptopus::Acts::AsWiki
ActiveRecord::Base.send :include, Hoptopus::Has::Formatter
include Hoptopus::EventFormatters