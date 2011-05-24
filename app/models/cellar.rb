require 'set'

class Cellar
  include MongoMapper::Document

  many :beers
  belongs_to :user
  timestamps!

  scope :newest, sort(:created_at.desc).limit(15)
  scope :oldest, sort(:created_at).limit(15)

  def self.find_by_user(user)
    if user.nil? or user.id < 1
      return nil
    end

    return Cellar.where(:user_id => user.id).first
  end

  def self.find_by_username(username)
    return Cellar.find_by_user User.find_by_username(username)
  end
end
