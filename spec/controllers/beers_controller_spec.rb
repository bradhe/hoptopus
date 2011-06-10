require 'spec_helper'

describe BeersController do
  describe '#create' do
    before do
      @user = create_confirmed_user(:confirmed => true)
      @controller.current_user = @user
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
