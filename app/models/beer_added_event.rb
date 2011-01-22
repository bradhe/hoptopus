class BeerAddedEvent < ActiveRecord::Base
  belongs_to :event
  belongs_to :beer
end
