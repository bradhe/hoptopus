class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  def self.admin_role
    return Role.where(:name => "Hoptopus Admin").first
  end
end
