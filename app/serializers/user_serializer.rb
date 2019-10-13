class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :bio, :username,
              :created_at, :deleted_at

  has_many :posts
  has_many :categories

  has_many :bookmarks

  has_many :thread_followings

  # show all posts (hidden, draft, published) belonging to the current user,
  # show only published posts if a user is viewing another user's profile
  def posts
    new_posts = []
    object.posts.each do |post|
      next if ((post.hidden? || post.draft?) && !is_current_user?(post.user))
      new_posts.push post
    end
    new_posts
  end

  attribute :email do
    object.email if is_current_user? || current_user.admin?
  end

  attribute :role do
    object.role if current_user.admin?
  end

  def thread_followings
    object.thread_followings if is_current_user?
  end

  # TODO: ensure the file is returned appropriately
  attribute :avatar do
    object.avatar.filename if object.avatar.attached?
  end

  attribute :active do
    object.active
  end

  private

  def is_current_user?(user = object)
    user == current_user
  end
end
