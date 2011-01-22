class BrewTastedEvent < ActiveRecord::Base
  belongs_to :brew
  belongs_to :event
  belongs_to :tasting
end
