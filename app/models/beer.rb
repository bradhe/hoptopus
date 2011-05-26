class Beer
  include MongoMapper::Document

  ACCEPTED_YEARS_FROM_TODAY = 2
  MAXIMUM_BEER_YEAR = Time.new.year + ACCEPTED_YEARS_FROM_TODAY
  YEAR_OF_OLDEST_BEER = 1800

  key :name, String
  key :brewery, String
  key :quantity, Integer
  key :cellared_at, Time
  key :bottle_size, String
  key :finish_aging_at, Time
  key :abv, Float
  key :price, Float
  key :year, Integer

  belongs_to :user
  has_many :tastings

  validates_presence_of :cellared_at, :message => "Cellared date is required."
  validates_numericality_of :year, :message => "Year is invalid. Is must be a four digit number between #{YEAR_OF_OLDEST_BEER} and #{MAXIMUM_BEER_YEAR}.", :only_integer => true, :greater_than => YEAR_OF_OLDEST_BEER, :less_than => MAXIMUM_BEER_YEAR
  validates_numericality_of :quantity, :message => "Quantity must be a number less than 120.", :less_than => 120
  validates_numericality_of :abv, :message => "ABV must be a decimal less than 150.", :less_than_or_equal_to => 150, :allow_nil => true
  validates_numericality_of :price, :message => "Please supply a valid price.", :allow_nil => true
end
