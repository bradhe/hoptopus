class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  before_filter :restore_session
  
  def restore_session
    unless session[:user_id].nil?
      begin
        login_user User.find(session[:user_id])
      rescue
        session[:user_id] = nil
      end
    end
  end
  
  def login_user(user)
    @user = user
    
    if session[:user_id] != user.id
      session[:user_id] = user.id
      
      # Update the last login date for this guy
      user.last_login_at = Time.now
      user.save!
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
  
  def render_404
    render :file => "404", :layout => false, :status => 404
  end
end
