class Event < ActiveRecord::Base
  include Hoptopus::Has::Formatter

  belongs_to :user
  belongs_to :source, :polymorphic => true
end
