FactoryBot.define do
  factory :cardio_exercise do
    sequence(:name) { |n| "Cardio Exercise #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
