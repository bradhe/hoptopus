require 'test_helper'

class BeerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "should not save a beer in the future" do
    beer = beers(:Valid_Beer)
    beer.year = Time.new.year + Beer::ACCEPTED_YEARS_FROM_TODAY + 1
    assert (not beer.valid?)
  end
  
  test "should not save a beer too far in the past" do
    beer = beers(:Valid_Beer)
    beer.year = Beer::YEAR_OF_OLDEST_BEER - 1
    assert (not beer.valid?)
  end
end
