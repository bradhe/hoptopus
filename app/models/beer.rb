class Beer < ActiveRecord::Base
  ACCEPTED_YEARS_FROM_TODAY = 2
  MAXIMUM_BEER_YEAR = Time.new.year + ACCEPTED_YEARS_FROM_TODAY
  YEAR_OF_OLDEST_BEER = 1800

  acts_as_commentable
  acts_as_wiki

  belongs_to :brew
  belongs_to :cellar
  has_one :user, :through => :cellar
  has_many :tasting_notes, :through => :brew, :include => :user
  belongs_to :bottle_size
  
  validates_presence_of :brew_id, :message => "Please select a beer."
  validates_presence_of :cellared_at, :message => "Cellared date is required."

  validates_numericality_of :year, :message => "Year is invalid. Is must be a four digit number between #{YEAR_OF_OLDEST_BEER} and #{MAXIMUM_BEER_YEAR}.", :only_integer => true, :greater_than => YEAR_OF_OLDEST_BEER, :less_than => MAXIMUM_BEER_YEAR
  validates_presence_of :cellared_at, :message => "Cellared date is required."

  validates_numericality_of :quantity, :message => "Quantity must be a number less than 120.", :less_than => 120
  validates_numericality_of :abv, :message => "ABV must be a decimal less than 150.", :less_than_or_equal_to => 150, :allow_nil => true
  validates_numericality_of :price, :message => "Please supply a valid price.", :allow_nil => true
  
  def formatted_cellared_at
    self.cellared_at.strftime "%A %B %d, %Y" unless self.cellared_at.nil?
  end
  
  def bottle_size_name
    self.bottle_size.name
  end
  
  def formatted_price
    self.price ? '$%#.2f' % self.price : 'Unknown'
  end
end
