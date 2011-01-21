class Beer < ActiveRecord::Base
  belongs_to :brew
  has_one :cellar
  has_many :tastings
  belongs_to :bottle_size
end
