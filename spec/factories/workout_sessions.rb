FactoryBot.define do
  factory :workout_session do
    association :student_profile
    association :training
    completed_at { nil }

    trait :completed do
      completed_at { Time.current }
    end

    trait :in_progress do
      completed_at { nil }
    end
  end
end
