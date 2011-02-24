#if Rails.env == "development"
#  ENV["REDIS_URL"] ||= "redis://localhost/"
#else
  ENV["REDIS_URL"] ||= "redis://redistogo:7fceeac29ebc5d3fbdf8c030af07b4e7@goosefish.redistogo.com:9623/"
#end

uri = URI.parse(ENV["REDIS_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
