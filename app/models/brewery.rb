class Brewery < ActiveRecord::Base
	has_many :brews
  
  before_save do
    self.sanitized_name = name.downcase.gsub(/[^\w]/, '') unless name.nil?
  end
  
  validates_presence_of :name, :message => 'A name is required.'
  validates_uniqueness_of :name, :case_sensitive => false, :message => 'A brewery by that name already exists.'
end
