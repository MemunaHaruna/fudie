class Flag < ApplicationRecord
  belongs_to :flaggable, polymorphic: true

  validates_uniqueness_of :flaggable_id, scope: [:flagger_id, :flaggable_type]
end
