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
end
