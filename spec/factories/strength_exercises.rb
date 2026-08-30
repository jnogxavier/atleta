FactoryBot.define do
  factory :strength_exercise do
    sequence(:name) { |n| "Strength Exercise #{n}" }
    description { Faker::Lorem.paragraph }
    muscle_group { %w[chest back legs shoulders arms core].sample }
    equipment { %w[barbell dumbbell machine bodyweight cable].sample }
  end
end
