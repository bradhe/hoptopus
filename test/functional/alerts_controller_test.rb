require 'test_helper'

class AlertsControllerTest < ActionController::TestCase
  test "should get dismiss" do
    user = users(:valid_user)
    get :dismiss, {}, {:user_id => user.id}
    assert_response :success
  end

end
