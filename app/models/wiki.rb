class Wiki < ActiveRecord::Base
  belongs_to :for, :polymorphic => true
end
