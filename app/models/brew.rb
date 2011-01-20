class Brew < ActiveRecord::Base
	belongs_to :brewery
	has_many :beers
	has_many :tastings, :through => :beers
end
