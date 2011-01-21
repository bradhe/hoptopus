class Beer < ActiveRecord::Base
  belongs_to :brew
  has_one :cellar
  has_many :tastings
  belongs_to :bottle_size
  
  validates_presence_of :brew_id, :message => 'Please select a beer.'
  validates_presence_of :year, :message => 'Year is required.'
  validates_presence_of :cellared_at, :message => 'Cellared date is required.'
  validates_presence_of :quantity, :message => 'Quantity is required.'
  
  validates_numericality_of :quantity, :message => 'Quantity must be a number less than 120.', :less_than => 120
  validates_numericality_of :abv, :message => 'ABV must be a decimal less than 100.', :less_than_or_equal_to => 100
  validates_format_of :year, :with => /^\d{4}$/, :message => 'Year must be a 4-digit number.'
  validates_numericality_of :price, :message => 'Invalid price, bro.'
end
