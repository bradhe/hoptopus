class Cellar < ActiveRecord::Base
	has_many :beers
	belongs_to :user
	
	def self.find_by_user(user)
		if user.nil? or user.id < 1
			return nil
		end
		
		return Cellar.find_by_user_id(user.id)
	end
end
