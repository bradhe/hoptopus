require 'spec_helper'

describe UsersController do
  before do
    @user = create_user(:confirmed => false)
    session[:user_id] = @user.id.to_s
  end

  describe '#confirm_email' do
    it 'should try to restore session' do
      @controller.should_receive(:restore_session)
      @controller.stub(:find_valid_confirmation).and_return(nil)
      get :confirm_email, { :confirmation_code => 'some_code' }
    end

    it 'should update the confirmation request and user confirmed fields' do
      # Ugh...
      obj = Object.new
      obj.should_receive(:update_attribute).with(:confirmed, true)
      @controller.stub(:find_valid_confirmation).and_return(obj)

      get :confirm_email, { :confirmation_code => '123aszx' }

      @user.reload
      @user.confirmed.should be_true
    end
  end

  describe '#send_confirmation' do
    it 'should set old confirmation requests to expired when a new one is sent' do
     confirmation = create_confirmation_request(:user => @user)

     # Look it up
     get :send_confirmation

     confirmation.reload
     confirmation.expired.should be_true
    end
  end
end
