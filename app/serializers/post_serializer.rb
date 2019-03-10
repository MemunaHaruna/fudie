class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :state

  belongs_to :user
  has_many :comments
  has_many :categories

end
