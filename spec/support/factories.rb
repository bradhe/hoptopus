def new_user(attributes={})
  default_attributes = { 
    :username => 'test_user',
    :password => '!!abc123',
    :password_confirmation => '!!abc123',
    :email => 'test@test.com'
  }

  User.new(default_attributes.merge(attributes.symbolize_keys))
end

def create_user(attributes={})
  u = new_user(attributes)
  u.save!
  u
end
