require 'test_helper'

class UserTest < ActiveSupport::TestCase  
  test "users with facebook_id do not need passwords" do
    user = users :no_password_user
    
    assert_not_nil user.facebook_id
    assert_nil user.password_hash
    
    # If the above are true, then this should be true.
    assert user.valid?
  end
end
