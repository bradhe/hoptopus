class Event < ActiveRecord::Base
  has_formatter
	belongs_to :user
  belongs_to :source, :polymorphic => true

  has_many :beer_added_events
  has_many :brew_edited_events
  has_many :brew_added_events
  has_many :brew_tasted_events
end
