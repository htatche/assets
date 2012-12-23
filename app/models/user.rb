class User < ActiveRecord::Base
  has_and_belongs_to_many :empresas
  attr_accessor :password
  attr_accessible :nom, :cognoms, :username, :email, :password, :password_confirmation

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
    :presence => true

  validates_length_of :password,
    :in => 6..20,
    :on => :create,
    :if => :password

  before_save :encrypt_password
  after_save :clear_password

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
      user = User.find_by_email(username_or_email)
    else
      user = User.find_by_username(username_or_email)
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
end
