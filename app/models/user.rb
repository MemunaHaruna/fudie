class User < ApplicationRecord
  has_secure_password

  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email
  validates :password, length: {:within => 6..40}

  enum role: %w[member admin]
end
