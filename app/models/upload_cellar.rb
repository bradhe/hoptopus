class UploadCellar
  extend ActiveModel::Naming 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  
  attr_accessor :file, :is_incremental
  
  validates_presence_of :file, :message => 'Please select a file.'
end