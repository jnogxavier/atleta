FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    terms_accepted { true }
    registration_status { :complete }
    role { :student }
    sequence(:name) { |n| "User Name #{n}" }

    trait :draft do
      registration_status { :draft }
      password { nil }
      password_confirmation { nil }
      password_digest { nil }
      terms_accepted { false }
    end

    trait :admin do
      role { :admin }
    end

    trait :student do
      role { :student }
    end

    trait :partner do
      role { :partner }
    end

    trait :with_anamnese do
      after(:create) do |user|
        create(:anamnese, user: user)
      end
    end

    trait :with_student_profile do
      after(:create) do |user|
        create(:student_profile, user: user)
      end
    end

    trait :with_partner_profile do
      after(:create) do |user|
        create(:partner_profile, user: user)
      end
    end

    trait :draft_student do
      role { :student }
      registration_status { :draft }
      terms_accepted { false }
    end

    trait :complete_student do
      role { :student }
      after(:create) do |user|
        create(:anamnese, user: user)
        create(:student_profile, user: user)
      end
    end

    trait :complete_partner do
      role { :partner }
      after(:create) do |user|
        create(:partner_profile, user: user)
      end
    end

    trait :inactive do
      deactivated_at { 1.day.ago }
      deactivation_reason { 'Test deactivation' }
      deactivated_by_id { 1 }
    end

    trait :active do
      deactivated_at { nil }
    end
  end
end
