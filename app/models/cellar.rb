require 'set'

class Cellar < ActiveRecord::Base
  acts_as_commentable

  has_many :beers
  has_many :brews, :through => :beers, :select => 'DISTINCT brews.*' 
  belongs_to :user

  def self.find_by_user(user)
    if user.nil? or user.id < 1
      return nil
    end
    
    return Cellar.where(:user_id => user.id).first
  end
  
  def breweries
	s = Set.new
	brews.each { |b| s << b.brewery_id }
	Brewery.order('name').where('id IN (?)', s.to_a).all
  end
end
