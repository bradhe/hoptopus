class OauthController < ApplicationController
  def facebook_connect
    redirect_to client.web_server.authorize_url(:redirect_uri => oauth_facebook_return_url, :scope => 'email,offline_access')
  end
  
  def facebook_return
    access_token = client.web_server.get_access_token(params[:code], :redirect_uri => oauth_facebook_return_url)
    u = JSON.parse(access_token.get('/me'))

    # Do login stuff here.
    hoptopus_user = User.find_by_email u["email"]
    
    # If we found a user, lets update their facebook_id
    # TODO: Add this here!
    if hoptopus_user
      login_user hoptopus_user
    end
    
    redirect_to root_path
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
