class User < ActiveRecord::Base
  attr_accessor :password

  has_one :cellar, :dependent => :destroy
  has_many :beers, :through => :cellar
  has_many :tastings, :through => :beers, :source => :cellar
  has_many :events
  has_many :alerts

  validates_presence_of :email, :message => 'Please provide an email address.'
  validates_presence_of :username, :message => 'Please provide a username.'
  validates_length_of :username, :in => 4..16, :message => 'Usernames must be between 4 and 16 characters long.'
  validates_format_of :email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not an email address!'
  validates_format_of :username, :with => /^\S+$/, :message => 'No spaces allowed in username.'
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'There is already an account with that email address.'
  validates_uniqueness_of :username, :case_sensitive => false, :message => 'There is already an account with that username.'

  # We do not want to do these for OAuth clients
  validates_presence_of :password, :message => 'Please provide a password.', :if => Proc.new { |u| u.facebook_id.nil? and !u.password_hash }
  validates_confirmation_of :password, :message => 'Passwords do not match.', :if => Proc.new { |u| u.facebook_id.nil? and !u.password_hash }
  validates_length_of :password, :minimum => 4, :message => 'Passwords must be at least 4 characters long.', :if => Proc.new { |u| !u.password_hash and u.facebook_id.nil? }

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
