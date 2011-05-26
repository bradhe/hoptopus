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

  describe '#has_alert?' do
    before do
      @user = create_user

      # Add the alert
      @user.alerts << Alert.new(:name => 'test_alert')
      @user.save!
    end

    it 'should return true if the user has the alert' do
      @user.has_alert?('test_alert').should be_true
    end

    it 'should return false if the user does not have the alert' do
      @user.has_alert?('some_other_alert').should be_false
    end
  end

  describe '#find_alert' do
    before do
      @user = create_user

      # Add the alert
      @user.alerts << Alert.new(:name => 'test_alert')
      @user.save!
    end

    it 'should return an alert if it exists' do
      @user.find_alert('test_alert').should be_a_kind_of Alert
    end

    it 'should return nil if no alert exists' do
      @user.find_alert('nonexistent_alert').should be_nil
    end
  end
end
