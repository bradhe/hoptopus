class Event < ActiveRecord::Base
	belongs_to :user
	
	UPDATED_CELLAR = 1
	ADDED_BREW = 2
	ADDED_BREWERY = 3
	TASTED = 4
end
