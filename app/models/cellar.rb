require 'set'

class Cellar
  include MongoMapper::Document

  many :beers
  belongs_to :user
  timestamps!

  scope :newest, sort(:created_at.desc).limit(15)
  scope :oldest, sort(:created_at).limit(15)

  def self.find_by_user(user)
    return nil if user.nil?
    return Cellar.find_by_user_id(user.id)
  end

  def self.find_by_username(username)
    raise "Deprecated."
  end

  def breweries
    self.beers.map{|b| b.brewery}.sort.uniq
  end
end
