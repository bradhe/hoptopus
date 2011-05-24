class ConfirmationRequest
  include MongoMapper::Document

  key :confirmation_code, String
  key :expired, Boolean, :default => false
  key :confirmed, Boolean, :default => false
  belongs_to :user
  timestamps!

  before_create do
    self.confirmation_code ||= Digest::SHA1.hexdigest(Time.now.to_s)
  end
end
