require 'spec_helper'

describe OauthController do

  describe '#facebook_return' do
    before do
      @user = new_user

      token = OAuth2::AccessToken.new nil, nil
      token.stubs(:get).returns({ :id => '1234', :email => @user.email }.to_json)
      OAuth2::Strategy::WebServer.any_instance.stubs(:get_access_token).returns(token)
    end

    it 'should populate facebook_id and email if request is users first login from fb' do
      get :facebook_return
      response.should redirect_to(facebook_register_path)
    end
  end
end
