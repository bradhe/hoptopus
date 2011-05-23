source :rubygems

gem 'rails', '3.0.7'
gem 'rack-rewrite'
gem 'maruku'
gem 'carmen'
gem 'geokit'
gem 'acts_as_commentable'
gem 'resque'
gem 'uuidtools'
gem 'aws-s3'
gem 'gravatar'
gem 'oauth2', :git => 'git://github.com/intridea/oauth2.git'
gem 'log4r'
gem 'haml'
gem 'sass'
gem 'mongo_mapper'
gem 'bson_ext'

# No SystemTimer gem on windows.
unless RUBY_PLATFORM =~ /ming/
  gem 'SystemTimer'
end

group :development, :test do
  gem 'rspec', '~>2.5.0'
  gem 'rspec-rails'
  gem 'mongrel'
end
