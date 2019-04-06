class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :state, :depth, :parent_id

  belongs_to :user
  has_many :comments
  has_many :categories

  has_many :votes
  has_many :bookmarks

  attribute :active do
    object.active
  end
end
