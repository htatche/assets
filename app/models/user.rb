class User < ActiveRecord::Base
  has_and_belongs_to_many :empresas
  attr_accessor :password
  attr_accessible :nom, :cognoms, :username, :email, :password

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$/i

  validates :nom,
    :presence => true

  validates :cognoms,
    :presence => true

  validates :username,
    :presence => true

  validates :username,
    :uniqueness => true,
    :length => { :in => 3..20 },
    :if => :username

  validates :email, :presence => true

  validates :email,
    :uniqueness => true,
    :format => EMAIL_REGEX,
    :if => :email

  validates :password,
    :presence => true,
    :on => :create

  validates_length_of :password,
    :in => 6..20,
    :confirmation => true,
    :on => :create,
    :if => :password

  before_create :generate_confirmation_code
  before_save :encrypt_password#, :only => [:create, :update]
  after_save :clear_password#, :only => [:create, :update]

  scope :certified, where(:confirmed => true)

  def encrypt_password
     if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def clear_password
    self.password = nil
  end

  def self.authenticate(username_or_email="", login_password="")
    if EMAIL_REGEX.match(username_or_email)    
      user = certified.find_by_email(username_or_email)
    else
      user = certified.find_by_username(username_or_email)
    end

    if user && user.match_password(login_password) 
      return user
    else
      return false
    end
  end   

  def match_password(login_password="")
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end

  def generate_confirmation_code
    self.confirmation_code = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.confirmed = 0
  end

  def match_confirmation_code(code)
    if confirmation_code == code
      self.confirmation_code = nil
      self.confirmed = true

      return true
    else
      return false
    end

  end
end
