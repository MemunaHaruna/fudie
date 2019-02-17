class User < ApplicationRecord
  has_secure_password

  validates_presence_of :username, :email
  validates_uniqueness_of :email
  validates :password, length: { minimum: 8 }

  enum role: %w[member admin]
end
