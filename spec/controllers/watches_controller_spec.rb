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
