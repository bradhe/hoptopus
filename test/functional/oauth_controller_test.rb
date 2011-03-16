require 'test_helper'
require 'mocha'

class OauthControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "can associate account with facebook_id in session from credentials" do
    post :associate_facebook_with_account, {:username => 'facebook_user1', :password => '!!abc123'}, { :registration => { :facebook_id => 123 } }
    assert_redirected_to root_url
    
    # We should make sure that the user's facebook_id was updated.
    user = users(:facebook_association_user)
    assert_equal 123, user.facebook_id, 'Facebook ID was not set by associate_facebook_with_account.'
  end
  
  test "on first-time login via facebook populate facebook_id and email in session" do
    # OAuth returns JSON from FB. We need to mock out that process.
    token = OAuth2::AccessToken.new nil, nil
    token.stubs(:get).returns({ :id => 1, :email => 'test@test.com' }.to_json)
    OAuth2::Strategy::WebServer.any_instance.stubs(:get_access_token).returns(token)

    get :facebook_return
    
    # We should have registration data in session
    assert session.has_key? :registration
    assert_equal 1, session[:registration][:facebook_id], 'Facebook ID was not populated in session during a first-time login.'
    assert_equal 'test@test.com', session[:registration][:email], 'Email returned by Facebook was not populated in session during a first-time login.'
    
    # We should also have 
    assert_redirected_to select_username_path
  end
end
