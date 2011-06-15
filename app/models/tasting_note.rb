class TastingNote < ActiveRecord::Base
  belongs_to :beer
  has_many :events, :dependent => :destroy

  def self.find_by_user(user)
    self.find_by_user_id(user.id) unless user.nil?
  end

  def cellar
    beer.cellar
  end

  def user
    cellar.user
  end

  after_create do
    Event.create!(:user => self.user, :source => self, :formatter => BeerTastedEventFormatter)
  end
end
