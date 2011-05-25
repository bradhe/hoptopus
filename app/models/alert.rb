class Alert
  include MongoMapper::EmbeddedDocument

  belongs_to :user
  key :name, String
  key :dismissed, Boolean, :default => false
end
