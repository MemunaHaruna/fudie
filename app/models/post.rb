class Post < ApplicationRecord
  belongs_to :user

  validates_presence_of :title, :body
  validates_uniqueness_of :title, scope: :user_id

  enum state: %w[draft published private]
end
