require 'spec_helper'

describe BeersController do
  describe '#index' do
    it 'should not require authentication' do
      pending
    end
  end

  describe '#create' do
    before do
      User.destroy_all
      @user = create_user
    end

    it 'should create a beer if all the required fields are given' do
      beer_hash = {
        :name => 'Some Beer',
        :brewery => 'Some Brewery',
        :cellared_at => Time.now,
      }

      lambda {
        post :create, { :cellar_id => @user.cellar.id, :beer => beer_hash }
      }.should change(Event, :count).by(1)
    end
  end
end
