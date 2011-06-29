require 'spec_helper'

describe AuthController do
  before do
    @user = new_user
  end

  describe '#login' do
    it 'should call login_user when there is a successful login' do
      User.stubs(:authenticate_without_password_hash).returns(@user)
      @controller.expects(:login_user).with(@user)

      post :login
    end

    it 'should redirect to the users cellar on successful login' do
      User.stubs(:authenticate_without_password_hash).returns(@user)
      @controller.stubs(:login_user) # don't do anything -- this might send an email.
      post :login
      @response.should be_redirect
    end

    it 'should render the login template on GET' do
      get :login
      @reponse.should render_template('login')
    end

    it 'should render the login template on GET even when params are passed!' do
      get :login, { :email => 'trololo@lololo.com', :password => 'some_password' }
      @reponse.should render_template('login')
    end
  end

  describe '#logout' do
    it 'should redirect to root_url all the time' do
      get :logout
      @response.should be_redirect
    end
  end

  describe '#register' do
    it 'should re-render the register template if the model is invalid' do
      obj = mock(:valid? => false)
      User.stubs(:create).returns obj

      post :register
      @response.should render_template('register')
    end

    it 'should create a user if all the fields are supplied' do
      user = { 
        :username => 'testuser', 
        :password => 'password',
        :password_confirmation => 'password', 
        :email => 'test@test.com', 
        :email_confirmation => 'test@test.com' 
      }

      # stubs login incase it's called too
      @controller.stubs(:login_user)

      fake_email = Object.new
      fake_email.stubs(:deliver)
      Notifications.stubs(:user_registered).returns(fake_email)

      lambda {
        post :register, { :user => user }
      }.should change(User, :count).by(1)
    end
  end

  describe '#confirm_password_reset' do
    describe 'with old request' do
      before do
        reset_request = stub(:created_at => (Time.now - 2.days), :confirmed => false)
        PasswordResetAttempt.stubs(:find_by_security_token).returns(reset_request)
      end

      it 'should redirect if the response is older than 2 days on get' do
        get :confirm_password_reset, :id => 'blah'
        response.should redirect_to request_password_reset_path
      end

      it 'should redirect if the response is older than 2 days on put' do
        put :confirm_password_reset, :id => 'blah'
        response.should redirect_to request_password_reset_path
      end
    end

    describe 'with invalid response' do
      before do
        PasswordResetAttempt.stubs(:find_by_security_token).returns(nil)
      end

      it 'should redirect if the response is not found on get' do
        get :confirm_password_reset, :id => 'blah'
        response.should redirect_to request_password_reset_path
      end

      it 'should redirect if the response is not found on put' do
        put :confirm_password_reset, :id => 'blah'
        response.should redirect_to request_password_reset_path
      end
    end

    describe 'with previously confirmed response' do
      before do
        reset_response = stub(:created_at => (Time.now - 1.days), :confirmed => true)
        PasswordResetAttempt.stubs(:find_by_security_token).returns(reset_response)
      end

      it 'should redirect if the response is previously confirmed on get' do
        get :confirm_password_reset, :id => 'blah'
        response.should redirect_to request_password_reset_path
      end

      it 'should redirect if the response is previously confirmed on put' do
        put :confirm_password_reset, :id => 'blah'
        response.should redirect_to request_password_reset_path
      end
    end

    describe 'with valid response' do
      before do
        reset_response = stub(:created_at => (Time.now - 1.days), :confirmed => false)
        PasswordResetAttempt.stubs(:find_by_security_token).returns(reset_response)
      end

      it 'should render the password and confirmed password template' do
        get :confirm_password_reset, :id => 'blah'
        response.should render_template('confirm_password_reset')
      end
    end

    describe 'with valid response on put' do
      before do
        reset_response = stub(:created_at => (Time.now - 1.days), :confirmed => false)
        PasswordResetAttempt.stubs(:find_by_security_token).returns(reset_response)
      end

      it 'should update the users password'
    end
  end
end
