class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  before_filter :restore_session
  
  def restore_session
    unless session[:user_id].nil?
      begin
        @user = User.find(session[:user_id])
      rescue
        session[:user_id] = nil
      end
    end
  end

  def redis
    @redis ||= begin
      uri = URI.parse(ENV["REDIS_URL"])
      Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end
  end
  
  def ensure_login
    unless @user
      redirect_to login_path
    end
  end
end
