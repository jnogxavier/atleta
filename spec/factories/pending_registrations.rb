FactoryBot.define do
  factory :pending_registration do
    sequence(:email) { |n| "pending#{n}@example.com" }
    sequence(:name) { |n| "Pending User #{n}" }
    sequence(:phone) { |n| "(11) 9#{9000 + n}-0000" }
    status { :pending }

    trait :pending do
      status { :pending }
    end

    trait :approved do
      status { :approved }
      approved_at { Time.current }
      association :approved_by, factory: :user, role: :admin
    end

    trait :rejected do
      status { :rejected }
      rejected_at { Time.current }
      association :rejected_by, factory: :user, role: :admin
      notes { 'Does not meet requirements' }
    end

    trait :with_notes do
      notes { 'Additional information about the registration' }
    end
  end
end
