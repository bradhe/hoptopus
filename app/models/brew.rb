class Brew < ActiveRecord::Base
	belongs_to :brewery
	belongs_to :brew_type
	has_many :beers
	has_many :tastings
end
