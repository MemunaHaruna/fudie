class User < ApplicationRecord
  has_secure_password
  attr_accessor :account_activation_token, :password_reset_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :username, presence: true, length: { maximum: 255 },
                      uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6, maximum: 20 }, on: :create

  validates_presence_of :password_digest

  enum role: %w[member admin]

  before_create :create_activation_digest
  before_save :downcase_email

  has_many :posts, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :thread_followings, class_name: 'ThreadFollowing', dependent: :destroy
  has_many :user_channels
  has_many :categories, through: :user_channels, dependent: :destroy
  has_many :flags, as: :flaggable

  has_one_attached :avatar

  scope :active, -> { where(deactivated_by_admin: false) }

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(account_activated: true, account_activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_password_reset_digest
    self.password_reset_token = User.new_token
    update_columns(password_reset_digest: User.digest(password_reset_token),
                    password_reset_sent_at: Time.zone.now
                  )
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  rescue => e
    raise ExceptionHandler::EmailNotSent, e.message
  end

  def password_reset_expired?
    password_reset_sent_at < 2.hours.ago
  end

  def reset_password!(password)
    if password.length < 6 || password.length > 20
      raise ExceptionHandler::InvalidParams, 'Password length must be between 6 and 20'
    end
    self.password_reset_token = nil
    self.password = password
    save!
  end

  def active
    deactivated_by_admin == false
  end

  def check_validity
    unless account_activated?
      message = 'Account unactivated. Check your email for activation link'
      raise ExceptionHandler::AuthenticationError, message
    end

    unless active
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end
  end

  def owner
    self
  end

  private

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.account_activation_token  = User.new_token
    self.account_activation_digest = User.digest(account_activation_token)
  end
end
