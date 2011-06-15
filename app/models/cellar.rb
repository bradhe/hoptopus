require 'set'

class Cellar < ActiveRecord::Base
  has_many :beers
  has_many :tasting_notes, :through => :beers
  belongs_to :user

  def self.newest
    order('created_at DESC').limit(15)
  end

  def self.oldest
    order(:created_at).limit(15)
  end

  def self.find_by_user(user)
    return nil if user.nil?
    Cellar.find_by_user_id(user.id)
  end

  def self.find_by_username(username)
    u = User.find_by_username(username)
    return nil if u.nil?
    u.cellar
  end

  def breweries
    self.beers.map{|b| b.brewery}.sort {|a,b| a.downcase <=> b.downcase}.uniq
  end

  def to_param
    self.user.username
  end
end
