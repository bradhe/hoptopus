class ContactRequest
  extend ActiveModel::Naming 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  
  attr_accessor :email, :subject, :body
  
  validates_presence_of :body, :message => 'Well? What would you like to say? Fill in the body.'
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'This is not a valid email address!'
  validates_presence_of :subject, :message => 'Subject is required.'
  
  def initialize(params={})
    params.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
  
  def persisted?
    false
  end
end
