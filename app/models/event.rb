class Event
  include MongoMapper::Document
  include Hoptopus::Has::Formatter

  belongs_to :user
  belongs_to :source, :polymorphic => true
  timestamps!
end
