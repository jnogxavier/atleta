FactoryBot.define do
  factory :student_profile do
    sequence(:name) { |n| "Student #{n}" }
    # StudentProfile#name is mirrored from the user by a before_save callback, so
    # the name has to reach the user or it is silently overwritten. An explicitly
    # passed user keeps its own name, which is what exercises that callback.
    user { association :user, role: :student, name: name }
    status { :active }
    expires_at { nil }

    trait :inactive do
      status { :inactive }
    end

    trait :suspended do
      status { :suspended }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :active_with_expiration do
      expires_at { 30.days.from_now }
    end

    trait :with_trainings do
      after(:create) do |profile|
        create_list(:training, 3, student_profile: profile)
      end
    end
  end
end
