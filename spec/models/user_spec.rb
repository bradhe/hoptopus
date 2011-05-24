require 'spec_helper'

describe User do
  before do
    @user = new_user
  end

  describe 'validation' do
    it 'should require a password if no password hash has been set' do
      @user.password = nil
      @user.password_hash = nil

      @user.should_not be_valid
      @user.errors[:password].should be_present
    end

    it 'should not require a password if facebook_id has been set' do
      @user.password = nil
      @user.password_hash = nil
      @user.facebook_id = 1234

      @user.should be_valid
      @user.errors[:password].should_not be_present
    end

    it 'should not require a password if password_hash has been set' do
      @user.password = nil
      @user.password_hash = "trololo"

      @user.should be_valid
      @user.errors[:password].should_not be_present
    end
  end
end
