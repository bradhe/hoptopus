require 'set'

class Cellar < ActiveRecord::Base
  has_many :beers
  belongs_to :user

  def self.newest
    sort('created_at DESC').limit(15)
  end

  def self.oldest
    sort(:created_at).limit(15)
  end

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
