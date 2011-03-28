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

  test "validators should be applied to all entities submitted for update" do
    # Update beers with ID 2. ABV must be a number.
    beers_hash = { '2' => { :abv => 'asdf', :quantity => 'asdfasdf' } }

    # Put updates should be JSON-y
    put :update, { :format => :json, :cellar_id => 'valid_user', :beer => beers_hash }, { :user_id => 1}

    assert_response :unprocessable_entity

    # Make sure that this is json
    json = nil
    p @response.body
    begin
      json = JSON.parse @response.body
    rescue
      # Just swallow the exception
    end

    assert_not_nil json, "Error response must be JSON"

    # There should be an "errors" item in the json payload
    assert json.has_key? 'errors'

    if json.has_key? 'errors'
      # Also assert that errors is an array
      assert_equal json['errors'].class, Hash

      # Should have an error for 2.
      assert json['errors'].has_key? '2'

      # Should have an error for ABV in hash with key 2
      assert json['errors']['2'].has_key? 'abv'
    end
  end
end