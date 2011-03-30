class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  before_filter :restore_session, :ensure_confirmed
  
  def restore_session
    unless session[:user_id].nil?
      begin
        login_user User.find(session[:user_id])
      rescue
        session[:user_id] = nil
      end
    end
  end

  def ensure_confirmed
    unless @user.nil? or @user.confirmed?
      redirect_to unconfirmed_path
    end
  end
  
  def login_user(user)
    # We should make sure that this user is confirmed. If they're not then we need to deliver an account
    # confirmation. They will automatically get redirected to the "confirm your account" page by the
    # rest of the app.
    unless user.confirmed?
      # Broke this up because I'm stupid
      unless ConfirmationRequest.where(:user_id => user.id, :confirmed => false, :expired => false).exists?
        confirmation_request = ConfirmationRequest.create :user => user
        Notifications.send_confirmation_request(confirmation_request).deliver
      end
    end

    @user = user
    
    if session[:user_id] != user.id
      session[:user_id] = user.id
      
      # Update the last login date for this guy
      user.last_login_at = Time.now
      user.save :validates => false
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
