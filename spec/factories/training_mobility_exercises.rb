FactoryBot.define do
  factory :training_mobility_exercise do
    association :training
    association :mobility_exercise
    sets { Faker::Number.between(from: 1, to: 3) }
    duration { Faker::Number.between(from: 15, to: 60).to_s }
    hold { Faker::Number.between(from: 10, to: 30).to_s }
    position { 0 }
    notes { Faker::Lorem.sentence }
  end
end
