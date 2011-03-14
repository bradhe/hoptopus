class OauthController < ApplicationController
  def facebook_connect
    redirect_to client.web_server.authorize_url(:redirect_uri => oauth_facebook_return_url, :scope => 'email,offline_access')
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

    access_token = client.web_server.get_access_token(params[:code], :redirect_uri => oauth_facebook_return_url)
    facebook = JSON.parse(access_token.get('/me'))

    logger.debug "Facebook: " + facebook.to_yaml

    # Do login stuff here.
    user = User.find_by_email facebook['email']

    # We might want to go somewhere else...    
    redirect_path = root_path

    if user and user.username and user.facebook_id != facebook.id
      # We will need the facebook user ID for later so...lets hang on to that.
      user.facebook_id = facebook['id']
      user.save!
    elsif not user
      user = User.new :email => facebook['email'], :facebook_id => facebook['id']
      
      # Skip validation so we don't error on missing username and password.
      user.save :validate => false

			# Also create a cellar for this user.
			cellar = Cellar.new(:user => user)
			cellar.save

      # Send notification email too
      Notifications.user_registered(user).deliver

      redirect_path = select_username_path
    elsif not user.username
      redirect_path = select_username_path
    end

    # Okay, finally ready to login the user.
    login_user user

    redirect_to redirect_path
  end
  
  def oauth_facebook_return_url
    uri = URI.parse(request.url)
    uri.path = facebook_return_path
    uri.query = nil
    uri.to_s
  end
  
  def client
    @client ||= OAuth2::Client.new(
      '54b28e424661a9bbd0b3d4848d1d19e9', 
      '3fc612064afc4075d9656eb1c6debf12', 
      :site => 'https://graph.facebook.com'
    )
  end
end
