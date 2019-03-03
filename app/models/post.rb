class Post < ApplicationRecord
  belongs_to :user

  validates_presence_of :title, :body
  validates_uniqueness_of :title, scope: :user_id
  validates :depth, numericality: { less_than_or_equal_to: 2, only_integer: true }

  enum state: %w[draft published hidden]

  has_many :comments, class_name: "Post",
                      foreign_key: "parent_id",
                      dependent: :destroy

  belongs_to :parent, class_name: "Post", optional: true
  has_many :votes, dependent: :destroy

  scope :posts_only, -> { where(parent_id: nil) } # posts only, not comments

  def set_depth
    if parent
      # nested comment: comment of a comment
      if parent.parent_id
        self.depth = 2
      else
        # comment to a post
        self.depth = 1
      end
    end
  end
end
