class Wiki < ActiveRecord::Base
  belongs_to :for, :polymorphic => true
  
  def to_html
    Maruku.new(markup).to_html
  end
end
