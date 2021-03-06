require 'spec_helper'

describe Beer do
  describe '#create' do
    it 'should create an event' do
      lambda {
        Beer.create!(:name => 'Test Beer', :brewery => 'Test Brewery', :cellared_at => Time.now, :cellar => create_cellar)
      }.should change(Event, :count).by(1)
    end

    it 'should not create an event if imported' do
      lambda {
        Beer.create!(:name => 'Test Beer', :brewery => 'Test Brewery', :cellared_at => Time.now, :cellar => create_cellar, :imported => true)
      }.should_not change(Event, :count).by(1)
    end
  end

  describe 'validation' do
    it 'should allow apostraphes in the brewery' do
      b = Beer.new(:brewery => "MacTarnahan's Brewing Co.")
      b.valid? # Trigger
      b.errors[:brewery].should_not be_present
    end

    it 'should allow apostraphes in the name' do
      b = Beer.new(:name => "Hale's Cream Stout")
      b.valid? # Trigger
      b.errors[:name].should_not be_present
    end

    it 'should allow dashes in the brewery' do
      b = Beer.new(:brewery => "Weizen-Bock")
      b.valid? # Trigger
      b.errors[:brewery].should_not be_present
    end

    it 'should allow apostraphes in the name' do
      b = Beer.new(:name => "Weizen-Bock")
      b.valid? # Trigger
      b.errors[:name].should_not be_present
    end
  end

  describe '#save' do
    before do
      @beer = create_beer
    end

    it 'should create an event if removed_at was nil and is updated to be not nil' do
      @beer.removed_at = Time.now

      lambda {
        @beer.save!
      }.should change(Event, :count).by(1)
    end

    it 'should not create an event if removed_at was not changed' do
      @beer.name = "Some other test name."

      lambda {
        @beer.save!
      }.should_not change(Event, :count)
    end
  end
end
