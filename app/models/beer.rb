class Beer < ActiveRecord::Base
  attr_accessor :imported

  ACCEPTED_YEARS_FROM_TODAY = 2
  MAXIMUM_BEER_YEAR = Time.new.year + ACCEPTED_YEARS_FROM_TODAY
  YEAR_OF_OLDEST_BEER = 1800

  belongs_to :cellar
  has_one :user, :through => :cellar
  has_many :tasting_notes, :dependent => :destroy
  has_many :events, :as => :source, :dependent => :destroy

  validates_presence_of :cellar_id
  validates_presence_of :cellared_at, :message => "Please supply a cellared date."
  validates_presence_of :brewery, :message => 'Please supply a brewery.'
  validates_presence_of :name, :message => 'Please supply a beer name.'
  validates_format_of :brewery, :with => /^[ \w\.'\-]*$/, :message => 'Brewery names can only contain dots, apostrophes, dashes, letters, numbers, and spaces.'
  validates_format_of :name, :with => /^[ \w\.'\-]*$/, :message => 'Beer names can only contain dots, apostrophes, dashes, letters, numbers, and spaces.'
  validates_numericality_of :year, :message => "Please supply a year. Is must be a four digit number between #{YEAR_OF_OLDEST_BEER} and #{MAXIMUM_BEER_YEAR}.", :only_integer => true, :greater_than => YEAR_OF_OLDEST_BEER, :less_than => MAXIMUM_BEER_YEAR, :allow_nil => true
  validates_numericality_of :quantity, :message => "Quantity must be a number less than 120.", :less_than => 120, :allow_nil => true
  validates_numericality_of :abv, :message => "ABV must be a decimal less than 150.", :less_than_or_equal_to => 150, :allow_nil => true
  validates_numericality_of :price, :message => "Please supply a valid price.", :allow_nil => true

  after_create do
    unless imported?
      Event.create!(:user => self.user, :source => self, :formatter => BeerAddedEventFormatter)
    end
  end

  after_save do
    if !removed_at_was and removed_at
      Event.create!(:user => self.user, :source => self, :formatter => BeerRemovedEventFormatter)
    end
  end

  def imported?
    @imported ||= false
    @imported
  end

  def self.importable_column_names
    Beer.column_names.sort - ['id', 'created_at', 'updated_at', 'cellar_id', 'removed_at']
  end

  def self.required_column_names
    ['name', 'brewery', 'year']
  end
end
