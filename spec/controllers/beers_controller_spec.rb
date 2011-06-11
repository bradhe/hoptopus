require 'spec_helper'

describe BeersController do
  describe '#create' do
    fixtures :users, :cellars

    it 'should create a beer if all the required fields are given' do
      sign_in_as(users(:user1))

      beer_hash = {
        :name => 'Some Beer',
        :brewery => 'Some Brewery',
        :cellared_at => Time.now,
        :year => 2011,
        :quantity => 1
      }

      lambda {
        post :create, { :cellar_id => @current_user.cellar.id, :beer => beer_hash }
      }.should change(Event, :count).by(1)
    end
  end
end
