class Tasting < ActiveRecord::Base
	belongs_to :user
	belongs_to :brew
	
	def self.find_by_user(user)
		if user.nil? 
			return nil
		end
		
		return self.find_by_user_id(user.id)
	end
  
  def self.find_by_brew(brew) 
    if brew.nil?
      return nil
    end
    
    return self.find_by_brew_id(brew.id)
  end
end
