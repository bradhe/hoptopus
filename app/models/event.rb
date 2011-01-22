class Event < ActiveRecord::Base
	belongs_to :user
  has_many :beer_added_events
  has_many :brew_edited_events
  has_many :brew_added_events
  has_many :brew_tasted_events
end
