require 'bcrypt'
class User
  include Mongoid::Document

  attr_accessor :password
  before_save :encrypt_password

  field :user_name, :type => String
  field :password_hash, :type => String
  field :password_salt, :type => String

  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_presence_of :user_name
  validates_uniqueness_of :user_name

  def self.authenticate(user_name, password)
    user = User.where(:user_name => user_name).first
    puts user.inspect
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

end
