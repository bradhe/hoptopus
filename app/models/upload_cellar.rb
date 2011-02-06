class UploadCellar
  extend ActiveModel::Naming 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  
  attr_accessor :file, :is_incremental
  
  validates_presence_of :file, :message => 'Please select a file.'
  
  def initialize(params={})
    params.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
  
  def persisted?
    false
  end
end