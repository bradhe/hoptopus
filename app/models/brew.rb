class Brew < ActiveRecord::Base
  belongs_to :brewery
  belongs_to :brew_type
  has_many :beers
  has_many :tastings
	
  validates_numericality_of :abv, :message => 'ABV must be a decimal less than 100.', :less_than_or_equal_to => 100, :allow_nil => true
  validates_numericality_of :ibus, :message => 'IBUs must be an integer less than 100.', :less_than_or_equal_to => 100, :allow_nil => true, :only_integer => true
end
