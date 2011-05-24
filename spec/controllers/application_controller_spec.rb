require 'spec_helper'

describe ApplicationController do
  before do
    User.collection.drop
    @user = new_user
  end

  describe '#login_user' do 
    it 'should check to see if a confirmation email has been sent' do
      obj = Object.new
      obj.stub(:exist?)

      ConfirmationRequest.should_receive(:where).with({
        :user_id => @user.id, 
        :confirmed => false, 
        :expired => false 
      }).and_return(obj)

      @controller.login_user(@user)
    end

    it 'should send a notification request if the user is not confirmed' do
      obj = Object.new
      obj.stub(:exist?)

      ConfirmationRequest.stub(:where).and_return(obj)

      # It should create a new confirmation request.
      lambda {
        @controller.login_user(@user)
      }.should change(ConfirmationRequest, :count).by(1)
    end

    it 'should stick the users id as a string in session when logged in' do
      ConfirmationRequest.stub(:exists?).and_return(true)

      @controller.login_user(@user)
      session[:user_id].should == @user.id.to_s

      # Also, the @user instance var should be set.
      @controller.current_user.should == @user
    end

    it 'should update the last login time for the user' do
      ConfirmationRequest.stub(:exists?).and_return(true)
      @user.should_receive(:update_attribute).with(:last_login_at, anything())

      @controller.login_user(@user)
    end
  end

  describe '#restore_session' do
    it 'should not call login user if no user_id is in session' do
      session[:user_id] = nil
      @controller.should_not_receive(:login_user)
      @controller.restore_session
    end

    it 'should set session[:user_id] to nil if a fucked up user_id is in session' do
      session[:user_id] = 'SOME USER ID THAT DOES NOT EXIST'
      @controller.restore_session
      session[:user_id].should be_nil
    end

    it 'should find the user if a valid user_id is in session' do
      u = create_user
      session[:user_id] = u.id.to_s
      @controller.should_receive(:current_user=).with(u)
      @controller.restore_session
    end

    it 'should actually load the user if there is a valid user_id in session' do
      u = create_user(:confirmed => true)
      session[:user_id] = u.id.to_s
      @controller.restore_session
    end
  end
end
