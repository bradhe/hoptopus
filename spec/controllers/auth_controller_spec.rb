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
    it 'should not try to save if the model is invalid' do
      obj = Object.new # mock model
      obj.expects(:valid?).returns false
      obj.expects(:save!).never

      User.stubs(:new).returns obj

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
end
