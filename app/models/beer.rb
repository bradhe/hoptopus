class Beer < ActiveRecord::Base
  belongs_to :brew
  has_one :cellar
end
