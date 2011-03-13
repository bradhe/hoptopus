class Event < ActiveRecord::Base
  has_formatter
	belongs_to :user
  belongs_to :source, :polymorphic => true
end
