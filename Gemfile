source :rubygems

gem 'rake', '0.8.7'
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

# No SystemTimer gem on windows.
unless RUBY_PLATFORM =~ /ming/
#  gem 'SystemTimer'
end

group :development, :test do
  gem 'rspec', '~>2.5.0'
  gem 'rspec-rails', '~>2.5.0'
  gem 'mongrel'
  gem 'jasmine'
  gem 'capistrano'
  gem 'sqlite3'
end
