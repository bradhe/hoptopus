require 'spec_helper'

describe HomeController do
  describe '#index' do
    it 'should redirect you to dashboard if you are logged in' do
      sign_in
      get :index
      response.should redirect_to(dashboard_path)
    end

    it 'should not redirect you if you are not logged in' do
      get :index
      response.should_not be_redirect
    end
  end
end
