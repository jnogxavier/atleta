FactoryBot.define do
  factory :training_strength_exercise do
    association :training
    association :strength_exercise
    sets { Faker::Number.between(from: 1, to: 5) }
    reps { Faker::Number.between(from: 6, to: 15) }
    rest { Faker::Number.between(from: 30, to: 120) }
    position { 0 }
    notes { Faker::Lorem.sentence }
  end
end
