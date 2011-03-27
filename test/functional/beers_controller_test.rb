require 'test_helper'

class BeersControllerTest < ActionController::TestCase
  test "posting multiple beer IDs to edit should load multiple beers" do
    post :edit, { :cellar_id => 'valid_user', :beer_id => [2, 3] }, { :user_id => 1 }

    assert_response :success
    assert assigns(:beers)
    
    # should load 2 beers
    assert_equal 2, assigns(:beers).length
  end
  
  test "posting multiple beer IDs should return multiple forms" do
    post :edit, { :cellar_id => 'valid_user', :beer_id => [2, 3] }, { :user_id => 1 }
    
    assert_response :success
    
    # Check the returned stuff
    assert_equal 2, css_select('div.edit.beer').length
  end
  
  test "should be able to edit multiple beers" do
    # Update beers with ID 2 and 3
    beers_hash = { '2' => { :abv => '1.50' }, '3' => { :quantity => '10' } }
    
    # Put updates should be JSON-y
    put :update, { :format => :json, :cellar_id => 'valid_user', :beer => beers_hash }, { :user_id => 1}
    
    assert_response :success
    
    # Now load these beers and make sure their values are different.
    assert_equal 1.50, Beer.find(2).abv
    assert_equal 10, Beer.find(3).quantity
  end

  test "when submitting multiple beers and there is errors in one then it should return those errors" do
    
  end
end