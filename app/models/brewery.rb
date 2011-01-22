class Brewery < ActiveRecord::Base
	has_many :brews
  
  validates_presence_of :name, :message => 'A name is required.'
  validates_uniqueness_of :username, :case_sensitive => false, :message => 'A brewery by that name already exists.'
end
