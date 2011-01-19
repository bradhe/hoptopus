class Beer < ActiveRecord::Base
	has_one :brew
  has_one :cellar
end
