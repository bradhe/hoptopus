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

    it 'should require a password if use_short_validation is true' do
      @user.password = nil
      @user.password_confirmation = nil
      @user.use_short_validation = true

      @user.should_not be_valid
      @user.errors[:password].length.should == 1
    end

    it 'should require a password confirmation if use_short_validation is false' do
      @user.password = "test_password"
      @user.password_confirmation = nil
      @user.use_short_validation = false

      @user.should_not be_valid
      @user.errors[:password_confirmation].length.should == 1
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

  describe '.search' do
    before do
      create_user(:email => 'bradhe@hippo.com', :username => 'bradhe')
      create_user(:username => 'test2', :email => 'trololo@test.com')
      create_user(:first_name => 'test1', :username => 'test1', :email =>'lol@lol.com')
      create_user(:last_name => 'test2', :username => 'some_other_guy', :email => 'foo@bar.com')
    end

    it 'should return multiple results when there are multiple hits' do
      User.search('test').should have(3).items
    end

    it 'should only return results that are pertinant' do
      User.search('test1').should have(1).items
    end
  end

  describe '#watching?' do
    it 'should return true if the user is watching the person' do
      user1 = new_user
      user2 = new_user

      user1.watches << user2
      user1.should be_watching(user2)
    end
  end
end
