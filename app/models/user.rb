class User < ActiveRecord::Base
  attr_accessor :password, :use_short_validation

  has_one :cellar, :dependent => :destroy
  has_many :events, :order => 'created_at DESC'
  has_many :alerts

  validates_presence_of :email, :message => 'Please provide an email address.'
  validates_presence_of :username, :message => 'Please provide a username.'
  validates_length_of :username, :in => 4..16, :message => 'Usernames must be between 4 and 16 characters long.'
  validates_format_of :email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not an email address!', :if => Proc.new { |u| u.confirm_email? }
  validates_format_of :username, :with => /^\S+$/, :message => 'No spaces allowed in username.'
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'There is already an account with that email address.'
  validates_uniqueness_of :username, :case_sensitive => false, :message => 'There is already an account with that username.'

  # We do not want to do these for OAuth clients
  validates_presence_of :password, :message => 'Please provide a password.', :if => :require_password?
  validates_length_of :password, :minimum => 4, :allow_nil => true, :message => 'Passwords must be at least 4 characters long.', :if => :require_password?
  validates_confirmation_of :password, :message => 'Passwords do not match.', :if => :confirm_password?
  validates_presence_of :password_confirmation, :message => 'Please confirm your password.', :if => :confirm_password?

  validates_confirmation_of :email, :message => 'Emails do not match.'

  before_create do
    self.password_hash = User.hash_password(password) if password
  end

  after_create do
    self.cellar = Cellar.create!(:user => self)
  end

  def to_param
    username
  end

  def confirmed?
    confirmed
  end

  def admin?
    admin
  end

  def has_alert?(name)
    alerts.exists?(:name => name)
  end

  def find_alert(name)
    alerts.where(:name => name).first
  end

  def tasting_notes
    cellar.tasting_notes
  end

  def beers
    cellar.beers
  end

  def use_short_validation?
    use_short_validation
  end

  def confirm_password?
    require_password? and !use_short_validation?
  end

  def require_password?
    !facebook_id and !password_hash
  end

  def confirm_email?
    use_short_validation?
  end

  def full_name
    unless first_name or last_name
      return nil
    end

    (first_name + ' ' + last_name).strip
  end

  def time_zone
    'Pacific Time (US & Canada)'
  end

  def location
    str = ""

    if(city)
      str += city
    end

    if(city and state)
      str += ', '
    end

    if(state)
      str += state
    end

    if(state and country)
      str += ', '
    end

    if(country)
      str += country
    end

    str.blank? ? nil : str
  end

  def self.search(str)
    token = "%#{str}%"

    # Prioitize username then everything else.
    (User.where('(username LIKE ?)', token) + User.where('(email LIKE ?) OR (first_name LIKE ?) OR (last_name LIKE ?)', token, token, token)).flatten.uniq
  end

  def self.hash_password(password)
    Digest::SHA256.hexdigest(password)
  end

  def self.authenticate_without_password_hash(email, password)
    return authenticate_with_password_hash(email, User.hash_password(password))
  end

  def self.authenticate_with_password_hash(email, password_hash)
    return User.where('(email = ? OR username = ?) AND password_hash = ?', email, email, password_hash).first
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
end
