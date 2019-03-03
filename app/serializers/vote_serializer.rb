class VoteSerializer < ActiveModel::Serializer
  attributes :id, :vote_type
  has_one :post
  has_one :user
end
