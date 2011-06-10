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
  default_attributes = { 
    :username => 'test_user',
    :password => '!!abc123',
    :password_confirmation => '!!abc123',
    :email => 'test@test.com'
  }

  User.create!(default_attributes.merge(attributes.symbolize_keys))
end

def create_confirmed_user(attributes={})
  new_user(attributes.merge(:confirmed => true))
end

def new_confirmation_request(attributes={})
  default_attributes = {
    
  }

  ConfirmationRequest.new(default_attributes.merge(attributes.symbolize_keys))
end

def create_confirmation_request(attributes={}) 
  c = new_confirmation_request(attributes)
  c.save!
  c
end

def new_beer(attributes={})
  default_attributes = {
    :name => 'Some Beer',
    :brewery => 'Some Brewery',
    :cellared_at => Time.now
  }

  Beer.new default_attributes.merge(attributes.symbolize_keys)
end
