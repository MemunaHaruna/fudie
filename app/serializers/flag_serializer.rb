class FlagSerializer < ActiveModel::Serializer
  attributes :id, :reason, :reviewed_by_admin, :flagger_id, :flaggable_type
  has_one :flaggable
end
