require 'test_helper'

class BeersControllerTest < ActionController::TestCase
  test "posting multiple beer IDs from cellar should return a form for all of those beers" do
    post :edit, { :cellar_id => 1, :beer_id => [2, 3] }

    assert_response :success
    assert_select 'div'
    assert_equal 2, css_select('div.edit.beer').length
  end
end