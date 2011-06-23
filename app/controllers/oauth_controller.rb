class OauthController < ApplicationController
  before_filter :ensure_hoptopus_domain

  def facebook_connect
    redirect_to client.web_server.authorize_url(:redirect_uri => facebook_return_url, :scope => 'email,offline_access')
  end

  def facebook_register
    if request.post? and @new_user = User.create(session[:registration])
      @new_user.save!
      Notifications.user_registered(@new_user).deliver

      # Also clean up their session.
      session.delete(:registration)

      # Finally, log in the guy.
      login_user(@new_user)

      redirect_to root_path
    elsif request.post?
      # Clear this to prevent some strange behavior.
      @new_user.username = nil
    else
      @new_user = User.new
      @email_address = session[:registration][:email]

      # Configure this in case we have matched an email address.
      if session.has_key?(:registration) and session[:registration].has_key?(:user_id)
        @matched_user = User.find(session[:registration][:user_id])
      end
    end
  end

  def associate_facebook_with_account
    email, password = params[:email], params[:password]
    user = User.authenticate_without_password_hash email, password

    if user
      user.facebook_id = session[:registration][:facebook_id]
      user.save!

      # Get rid of this shit.
      session.delete(:registration)

      login_user(user)

      redirect_to root_url
    else
      respond_to do |format|
        format.html { render :template => 'auth/login' }
      end
    end
  end

  def facebook_return
    if params[:error]
      logger.info "Facebook login error."
      logger.info "\tError: " + params[:error]
      logger.info "\tMessage: " + params[:error_description]

      # We're outta here.
      redirect_to root_path
      return
    end

    access_token = client.web_server.get_access_token(params[:code], :redirect_uri => facebook_return_url)
    facebook = JSON.parse access_token.get('/me')

    # Do login stuff here.
    user = User.where('facebook_id = ? OR email = ?', facebook['id'], facebook['email']).first

    # We might want to go somewhere else...    
    redirect_path = root_path

    if user and user.facebook_id == facebook['id'].to_i # Facebook IDs match. Who care's about email?
      # Okay, finally ready to login the user.
      login_user(user)
    elsif user and user.email == facebook['email'] # Facebook IDs don't match but emails do.
      session[:registration] = { :facebook_id => facebook['id'], :user_id => user.id }
      redirect_path = facebook_register_path
    else 
      session[:registration] = { :email => facebook['email'], :facebook_id => facebook['id'] }
      redirect_path = facebook_register_path
    end

    redirect_to redirect_path
  end

  def client
    @client ||= OAuth2::Client.new(
      '54b28e424661a9bbd0b3d4848d1d19e9', 
      '3fc612064afc4075d9656eb1c6debf12', 
      :site => 'https://graph.facebook.com'
    )
  end

  private
  def ensure_hoptopus_domain
    return unless Rails.env == 'development'

    unless request.host =~ /hoptopus\.com$/
      uri = URI.parse(request.url)
      uri.host = 'dev.hoptopus.com'
      redirect_to uri.to_s
    end
  end
end
