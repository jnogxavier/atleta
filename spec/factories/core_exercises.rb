FactoryBot.define do
  factory :core_exercise do
    sequence(:name) { |n| "Core Exercise #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
