require 'test_helper'
require 'mocha'

class OauthControllerTest < ActionController::TestCase
  test "when user logs in for the first time via facebook then populate facebook_id and email in session and request a registration" do
    mock_facebooks_json_response 1, 'test@test.com'
    get :facebook_return
    
    # We should have registration data in session
    assert session.has_key? :registration
    assert_equal 1, session[:registration][:facebook_id], 'Facebook ID was not populated in session during a first-time login.'
    assert_equal 'test@test.com', session[:registration][:email], 'Email returned by Facebook was not populated in session during a first-time login.'
    
    # We should also have been redirected to the register page
    assert_redirected_to facebook_register_path
  end
  
  test "when user without associated facebook account attempts to login via facebook they are redirected to register page" do
    mock_facebooks_json_response 1, "something@gmail.com"
    get :facebook_return
    assert_redirected_to facebook_register_path
  end
  
  test "when user with associated facebook account attempts to login via facebook they should be logged in" do
    user = users :user_with_facebook_id
    mock_facebooks_json_response user.facebook_id, user.email
    
    get :facebook_return
    assert_redirected_to root_path
    
    assert_equal user, assigns[:user]
  end
  
  test "when user with associated facebook account but different email addresses logs in via facebook they should be logged in" do
    user = users :user_with_facebook_id
    mock_facebooks_json_response user.facebook_id, "not_the_same@gmail.com"
    
    get :facebook_return
    assert_redirected_to root_path
    
    assert_equal user, assigns[:user]
        
    # This tests that we didn't fuck up the fixture somehow.
    assert_not_equal user.email, "not_the_same@gmail.com"
  end
    
  test "when user provides credentials to associate an existing account the facebook_id in session is assigned to that account" do
    post :associate_facebook_with_account, {:username => 'facebook_user1', :password => '!!abc123'}, { :registration => { :facebook_id => 123 } }
    assert_redirected_to root_url
    
    # We should make sure that the user's facebook_id was updated.
    user = users(:user_without_facebook_id)
    assert_equal 123, user.facebook_id, 'Facebook ID was not set by associate_facebook_with_account.'
    
    # Also make sure that the user was logged in
    assert_equal user, assigns[:user]
  end
  
  private
    def mock_facebooks_json_response(id, email)
      token = OAuth2::AccessToken.new nil, nil
      token.stubs(:get).returns({ :id => id, :email => email }.to_json)
      OAuth2::Strategy::WebServer.any_instance.stubs(:get_access_token).returns(token)
    end
end
