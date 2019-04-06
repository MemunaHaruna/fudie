FactoryBot.define do
  factory :flag do
    flagger_id { 1 }
    flaggable_id { 1 }
    reason { "offensive content" }
    reviewed_by_admin { false }

    trait :user_flag do
      flaggable_type { 'User' }
    end

    trait :post_flag do
      flaggable_type { 'Post' }

    end
  end
end
