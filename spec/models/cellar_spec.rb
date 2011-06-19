require 'spec_helper'

describe Cellar do
  describe '#active_beers' do
    before do
      @cellar = create_cellar
      @cellar.beers << new_beer(:name => 'Test Beer 1', :brewery => 'Test Brewery 1', :removed_at => Time.now)
      @cellar.beers << new_beer(:name => 'Test Beer 2', :brewery => 'Test Brewery 1')
    end

    it 'should only return beers that do not have removed_at' do
      @cellar.active_beers.length.should == 1
    end

    it 'should return an empty array if none of the beers are active' do
      @cellar.active_beers.each { |b| @cellar.beers.delete(b) }
      @cellar.active_beers.should be_empty
    end
  end

  describe '#removed_beers' do
    before do
      @cellar = create_cellar
      @cellar.beers << new_beer(:name => 'Test Beer 1', :brewery => 'Test Brewery 1', :removed_at => Time.now)
      @cellar.beers << new_beer(:name => 'Test Beer 2', :brewery => 'Test Brewery 1')
    end

    it 'should return beers that are removed' do
      @cellar.removed_beers.each { |b| b.removed_at.should_not be_nil }
    end
  end
end
