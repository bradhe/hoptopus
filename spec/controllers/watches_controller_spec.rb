require 'spec_helper'

describe WatchesController do
  describe '#create' do
    before do
      @user = create_user(:username => 'user1', :email => 'user1@gmail.com', :confirmed => true)
      create_user(:username => 'user2', :email => 'user2@gmail.com', :confirmed => true)

      sign_in_as(@user)
    end

    it 'should create a watch' do
      post :create, { :user_id => 'user2' }
      @user.watches.should have(1).item
    end

    it 'should create a watched event' do
      lambda {
        post :create, { :user_id => 'user2' }
      }.should change(Event, :count).by(1)
    end

    it 'should not create a watched event twice' do
      lambda {
        post :create, { :user_id => 'user2' }
        post :create, { :user_id => 'user2' }
      }.should change(Event, :count).by(1)
    end

    it 'should update an watched event if there is an old one' do
      post :create, { :user_id => 'user2' }

      e = Event.last
      e.update_attribute(:created_at,  6.days.ago)

      # Remove the watch too
      @user.watches.delete(User.find_by_username('user2'))

      mock_event = mock(:update_attribute)

      event = stub(:first => mock_event)
      Event.stubs(:where).returns(event)

      post :create, { :user_id => 'user2' }
    end

    it 'should send an email when a watch is created' do
      Notifications.expects(:watched).returns(mock(:deliver => nil))
      post :create, { :user_id => 'user2' }
    end

    it 'should not send emails if should_receive_email_notifications is false' do
      sign_in_as(create_user(:username => 'user3', :email => 'u1@gmail.com', :should_receive_email_notifications => false))
      Notifications.expects(:watched).never
      post :create, { :user_id => 'user2' }
    end
  end

  describe '#destroy' do
    before do
      @user = create_user(:username => 'user1', :email => 'user1@gmail.com', :confirmed => true)
      u = create_user(:username => 'user2', :email => 'user2@gmail.com', :confirmed => true)

      @user.watches << u

      sign_in_as(@user)
    end

    it 'should destroy a watch' do
      delete :destroy, { :id => 'user2' }
      @user.watches.should be_empty
    end
  end
end
