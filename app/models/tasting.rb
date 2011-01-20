class Tasting < ActiveRecord::Base
	belongs_to :user
	belongs_to :beer
	has_one :brew, :through => :beer
	
	def self.find_by_user(user)
		if user.nil? 
			return nil
		end
		
		return self.find_by_user_id(user.id)
	end
end
