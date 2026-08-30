FactoryBot.define do
  factory :mobility_exercise do
    sequence(:name) { |n| "Mobility Exercise #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
