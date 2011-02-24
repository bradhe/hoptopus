class Beer < ActiveRecord::Base
  acts_as_commentable
  acts_as_wiki

  belongs_to :brew
  belongs_to :cellar
  has_many :tastings
  belongs_to :bottle_size
  
  validates_presence_of :brew_id, :message => 'Please select a beer.'
  validates_presence_of :year, :message => 'Year is required.'
  validates_presence_of :cellared_at, :message => 'Cellared date is required.'

  validates_numericality_of :quantity, :message => 'Quantity must be a number less than 120.', :less_than => 120
  validates_numericality_of :abv, :message => 'ABV must be a decimal less than 150.', :less_than_or_equal_to => 150, :allow_nil => true
  validates_format_of :year, :with => /^\d{4}$/, :message => 'Year must be a 4-digit number.', :allow_nil => true
  validates_numericality_of :price, :message => 'Invalid price, bro.', :allow_nil => true

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
