class Event < ActiveRecord::Base
  include Hoptopus::Has::Formatter

  belongs_to :user
  belongs_to :source, :polymorphic => true

  def formatter
    self.formatter_type.constantize.new(self)
  end

  def formatter=(formatter)
    self.formatter_type = formatter.to_s
  end
end
