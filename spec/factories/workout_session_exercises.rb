FactoryBot.define do
  factory :workout_session_exercise do
    association :workout_session
    exercise_type { 'strength' }
    exercise_id { create(:training_strength_exercise).id }
    completed { false }

    trait :completed do
      completed { true }
    end

    trait :strength do
      exercise_type { 'strength' }
      exercise_id { create(:training_strength_exercise).id }
    end

    trait :cardio do
      exercise_type { 'cardio' }
      exercise_id { create(:training_cardio_exercise).id }
    end

    trait :core do
      exercise_type { 'core' }
      exercise_id { create(:training_core_exercise).id }
    end

    trait :mobility do
      exercise_type { 'mobility' }
      exercise_id { create(:training_mobility_exercise).id }
    end
  end
end
