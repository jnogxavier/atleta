FactoryBot.define do
  factory :session do
    association :user

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :active do
      expires_at { 30.days.from_now }
    end

    trait :expiring_soon do
      expires_at { 1.day.from_now }
    end
  end
end
