class Category < ApplicationRecord
  validates_uniqueness_of :name
  validates_presence_of :name

  has_many :user_channels, dependent: :destroy
  has_many :users, through: :user_channels

  has_many :posts_categories, dependent: :destroy
  has_many :posts, through: :posts_categories
end
