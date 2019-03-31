FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    body { "test content" }
    state { 1 }
    user
  end
end
