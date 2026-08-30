FactoryBot.define do
  factory :training_core_exercise do
    association :training
    association :core_exercise
    sets { Faker::Number.between(from: 1, to: 4) }
    rest { Faker::Number.between(from: 20, to: 60) }
    position { 0 }
    notes { Faker::Lorem.sentence }
  end
end
