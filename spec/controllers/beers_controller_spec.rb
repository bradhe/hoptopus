require 'spec_helper'

describe BeersController do
  describe '#create' do
    fixtures :users, :cellars

    before do
      @beer_hash = {
        :name => 'Some Beer',
        :brewery => 'Some Brewery',
        :cellared_at => Time.now,
        :year => 2011,
        :quantity => 1
      }

      sign_in_as(users(:user1))
    end

    it 'should create a beer if all the required fields are given' do
      lambda {
        post :create, { :cellar_id => @current_user.cellar.id, :beer => @beer_hash }
      }.should change(Beer, :count).by(1)
    end

    it 'should not create a tasting note if the tasting_note fields are all empty' do
      @beer_hash["tasting_note"] = {
        :aroma_rating=>"",
        :pour_rating=>"",
        :notes=>"",
        :appearance_rating=>"",
        :preference_rating=>"",
        :mouthfeel_rating=>"",
        :taste_rating=>"",
        :drinkability_rating=>""
      }

      lambda {
        post :create, { :cellar_id => @current_user.cellar.id, :beer => @beer_hash }
      }.should_not change(TastingNote, :count).by(1)
    end

    it 'should create a tasting note if at least one tasting_note field is not empty' do
      @beer_hash["tasting_note"] = {
        :notes=>"This is a note about tasting. It should be empty."
      }

      lambda {
        post :create, { :cellar_id => @current_user.cellar.id, :beer => @beer_hash }
      }.should change(TastingNote, :count).by(1)
    end
  end
end
