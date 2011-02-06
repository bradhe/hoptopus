class Cellar < ActiveRecord::Base
  acts_as_commentable

  has_many :beers
  belongs_to :user  

  def self.find_by_user(user)
    if user.nil? or user.id < 1
      return nil
    end
    
    return Cellar.where(:user_id => user.id).first
  end
end
