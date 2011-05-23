class User
  include MongoMapper::Document
  attr_accessor :password

  key :facebook_id, Integer
  key :username, String
  key :password_hash, String
  key :email, String
  key :first_name, String
  key :last_name, String
  key :country, String
  key :state, String
  key :city, String
  key :confirmed, Boolean
  key :admin, Boolean
  key :last_login_at, Time
  key :should_show_own_events, Boolean
  key :email_consent, Boolean
  key :should_receive_email_notifications, Boolean

  has_one :cellar, :dependent => :destroy
  many :tastings
  #many :events
  #many :alerts

  validates_presence_of :email, :message => 'Please provide an email address.'
  validates_presence_of :username, :message => 'Please provide a username.'
  validates_length_of :username, :in => 4..16, :message => 'Usernames must be between 4 and 16 characters long.'
  validates_format_of :email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not an email address!'
  validates_format_of :username, :with => /^\S+$/, :message => 'No spaces allowed in username.'
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'There is already an account with that email address.'
  validates_uniqueness_of :username, :case_sensitive => false, :message => 'There is already an account with that username.'

  # We do not want to do these for OAuth clients
  validates_presence_of :password, :message => 'Please provide a password.', :if => Proc.new { |u| u.facebook_id.nil? }
  validates_confirmation_of :password, :message => 'Passwords do not match.', :if => Proc.new { |u| u.facebook_id.nil? }
  validates_length_of :password, :minimum => 4, :message => 'Passwords must be at least 4 characters long.', :if => Proc.new { |u| u.facebook_id.nil? }

  validates_confirmation_of :email, :message => 'Emails do not match.'
  
  before_create do
    self.password_hash = hash_password(password) if password
  end

  def confirmed?
    self.confirmed
  end

  def is_admin?
    admin
  end

  def make_admin
    roles << Role::admin_role unless is_admin?
  end

  def disable
    
  end

  def revoke_admin
    roles.delete Role::admin_role
  end
  
  def formatted_created_at
    self.created_at.strftime "%A %B %d, %Y" unless self.created_at.nil?
  end
  
  def formatted_last_login_at
    self.last_login_at.strftime "%A %B %d, %Y" unless self.last_login_at.nil?
  end
  
  def self.hash_password(password)
    Digest::SHA256.hexdigest(password)
  end

  def self.authenticate_without_password_hash(email, password)
    return authenticate_with_password_hash(email, User.hash_password(password))
  end

  def self.authenticate_with_password_hash(email, password_hash)
    return User.where(:email => email, :password_hash => password_hash).first
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    # Get the user email info from Facebook for sign up
    # You'll have to figure this part out from the json you get back
    data = ActiveSupport::JSON.decode(access_token)

    if user = User.find_by_email(data["email"])
      user
    else
      # Create an user with a stub password.
      User.create!(:name => data["name"], :email => data["email"], :password => Devise.friendly_token)
    end
  end
  
  private
    def destroy_cellar
      self.cellar.destroy
    end
end
