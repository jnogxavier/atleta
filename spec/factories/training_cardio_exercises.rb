FactoryBot.define do
  factory :training_cardio_exercise do
    association :training
    association :cardio_exercise
    duration { Faker::Number.between(from: 10, to: 60) }
    intensity { %w[low moderate high].sample }
    calories { Faker::Number.between(from: 100, to: 500) }
    position { 0 }
    notes { Faker::Lorem.sentence }
  end
end
