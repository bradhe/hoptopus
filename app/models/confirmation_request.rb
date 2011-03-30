class ConfirmationRequest < ActiveRecord::Base
  belongs_to :user

  before_create do
    self.confirmation_code ||= Digest::SHA1.hexdigest(Time.now.to_s)
  end
end
