class ApplicationController < ActionController::Base
  helper :all
  before_filter :restore_session, :ensure_confirmed

  def restore_session
    begin
      if session[:user_id] and user = User.find(session[:user_id])
        # This prevents us from overwriting our test thing, but still
        # does the update!
        self.current_user ||= user
      else
        session[:user_id] = nil
      end
    rescue ActiveRecord::RecordNotFound => e
      session[:user_id] = nil
    end
  end

  def ensure_confirmed
    unless self.current_user.nil? or self.current_user.confirmed?
      redirect_to unconfirmed_path
    end
  end

  def require_authentication
    if self.current_user.nil?
      session[:redirect_from] = request.url
      redirect_to login_url
    end
  end

  def login_user(user)
    # We should make sure that this user is confirmed. If they're not then we need to deliver an account
    # confirmation. They will automatically get redirected to the "confirm your account" page by the
    # rest of the app.
    unless user.confirmed?
      # Broke this up because I'm stupid
      unless ConfirmationRequest.exists?(:user_id => user.id, :confirmed => false, :expired => false)
        confirmation_request = ConfirmationRequest.create!(:user => user)
        Notifications.send_confirmation_request(confirmation_request).deliver
      end
    end

    self.current_user = user

    session[:user_id] = user.id

    # Update the last login date for this guy
    user.update_attribute(:last_login_at, Time.now)
  end

  def redis
    @redis ||= begin
      uri = URI.parse(ENV["REDIS_URL"])
      Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end
  end

  def current_user
    @user
  end
  helper_method :current_user

  def current_user=(user)
    @user = user
  end

  def render_404
    render :file => "404", :layout => false, :status => 404
  end
end
