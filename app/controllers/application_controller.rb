class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  before_filter :restore_session, :ensure_confirmed

  def restore_session
    if session[:user_id] and user = User.find(session[:user_id])
      # This prevents us from overwriting our test thing, but still
      # does the update!
      self.current_user ||= user
    else
      session[:user_id] = nil
    end
  end

  def ensure_confirmed
    unless current_user.nil? or current_user.confirmed?
      redirect_to unconfirmed_path
    end
  end

  def login_user(user)
    # We should make sure that this user is confirmed. If they're not then we need to deliver an account
    # confirmation. They will automatically get redirected to the "confirm your account" page by the
    # rest of the app.
    unless user.confirmed?
      # Broke this up because I'm stupid
      unless ConfirmationRequest.where(:user_id => user.id, :confirmed => false, :expired => false).exist?
        confirmation_request = ConfirmationRequest.create(:user => user)
        Notifications.send_confirmation_request(confirmation_request).deliver
      end
    end

    self.current_user = user

    if session[:user_id] != user.id.to_s
      session[:user_id] = user.id.to_s

      # Update the last login date for this guy
      user.update_attribute(:last_login_at, Time.now)
    end
  end

  def redis
    @redis ||= begin
      uri = URI.parse(ENV["REDIS_URL"])
      Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end
  end
  
  def ensure_login
    redirect_to login_path unless current_user
  end

  def current_user
    @user
  end

  def current_user=(user)
    @user = user
  end
  
  def render_404
    render :file => "404", :layout => false, :status => 404
  end
end
