require 'spec_helper'

describe UsersController do
  before do
    User.collection.drop
    @user = create_user(:confirmed => false)
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

      @controller.current_user = @user
      @user.should_receive(:update_attribute).with(:confirmed, true)

      @controller.stub(:find_valid_confirmation).and_return(obj)

      session[:user_id] = @user.id.to_s
      get :confirm_email, { :confirmation_code => '123aszx' }
    end
  end
end
