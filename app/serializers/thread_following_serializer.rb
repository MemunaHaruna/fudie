class ThreadFollowingSerializer < ActiveModel::Serializer
  attributes :id, :post_id
  has_one :user
  has_one :post
end
