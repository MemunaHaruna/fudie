class Post < ApplicationRecord
  include Searchable
  include Recoverable

  validates_presence_of :title, :body
  validates_uniqueness_of :title, scope: :user_id
  validates :depth, numericality: { less_than_or_equal_to: 2, only_integer: true }

  enum state: %w[draft published hidden]

  has_many :comments, class_name: "Post",
                      foreign_key: "parent_id",
                      dependent: :destroy
  belongs_to :user
  belongs_to :parent, class_name: "Post", optional: true
  has_many :votes, dependent: :destroy
  has_many :thread_followings, class_name: 'ThreadFollowing', dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :posts_categories
  has_many :categories, through: :posts_categories, dependent: :destroy
  has_many :flags, as: :flaggable

  scope :active, -> { where(deactivated_by_admin: false, deleted_at: nil) }
  scope :posts_only, -> { where(parent_id: nil) } # posts only, not comments
  scope :only_soft_deleted, -> { where.not(deleted_at: nil)}

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

  def save_categories(categories)
    store(categories)
  rescue => error
    raise ActiveRecord::RecordInvalid, error.message
  end

  def update_categories(categories)
    PostsCategory.where(post_id: self.id).delete_all
    store(categories)
  rescue => error
    raise ActiveRecord::RecordInvalid, error.message
  end

  def active
    deactivated_by_admin == false && deleted_at.nil?
  end

  def owner
    user
  end

  private
    def store(categories)
      categories.each {|id| save_post_category(id) }
    end

    def save_post_category(id)
      PostsCategory.create!(post_id: self.id, category_id: id)
    end
end
