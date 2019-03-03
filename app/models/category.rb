class Category < ApplicationRecord
  validates_uniqueness_of :name

  has_many :users_categories, dependent: :destroy
  has_many :users, through: :users_categories

  has_many :posts_categories, dependent: :destroy
  has_many :posts, through: :posts_categories
end
