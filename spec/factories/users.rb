FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Name.unique.name }
    email { Faker::Internet.email }
    bio { Faker::Lorem.sentence }
    password "foobar"
  end
end
