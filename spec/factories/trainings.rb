FactoryBot.define do
  factory :training do
    association :student_profile
    sequence(:name) { |n| "Training #{n}" }
    day { %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].sample }
    active { true }
    description { Faker::Lorem.paragraph }

    trait :inactive do
      active { false }
    end

    trait :with_strength_exercises do
      after(:create) do |training|
        create_list(:training_strength_exercise, 3, training: training)
      end
    end

    trait :with_mobility_exercises do
      after(:create) do |training|
        create_list(:training_mobility_exercise, 2, training: training)
      end
    end

    trait :with_core_exercises do
      after(:create) do |training|
        create_list(:training_core_exercise, 2, training: training)
      end
    end

    trait :with_cardio_exercises do
      after(:create) do |training|
        create_list(:training_cardio_exercise, 1, training: training)
      end
    end

    trait :complete do
      after(:create) do |training|
        create_list(:training_strength_exercise, 3, training: training)
        create_list(:training_mobility_exercise, 2, training: training)
        create_list(:training_core_exercise, 2, training: training)
        create_list(:training_cardio_exercise, 1, training: training)
      end
    end
  end
end
