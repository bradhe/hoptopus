class BrewAddedEvent < ActiveRecord::Base
  belongs_to :event
  belongs_to :brew
end
