class TastingNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :beer
  has_many :events, :dependent => :destroy

  def self.find_by_user(user)
    self.find_by_user_id(user.id) unless user.nil?
  end
end
