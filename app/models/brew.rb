class Brew < ActiveRecord::Base
  acts_as_commentable
  acts_as_wiki

  belongs_to :brewery
  belongs_to :brew_type
  has_many :beers
  has_many :tastings
	
  validates_presence_of :name, :message => 'A name is required.'
  validates_numericality_of :abv, :message => 'ABV must be a decimal less than 100.', :less_than_or_equal_to => 100, :allow_nil => true
  validates_numericality_of :ibus, :message => 'IBUs must be an integer less than 100.', :less_than_or_equal_to => 100, :allow_nil => true, :only_integer => true
end
