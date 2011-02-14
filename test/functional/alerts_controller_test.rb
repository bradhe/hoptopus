require 'test_helper'

class AlertsControllerTest < ActionController::TestCase
  test "should get dismiss" do
    get :dismiss
    assert_response :success
  end

end
