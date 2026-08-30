FactoryBot.define do
  factory :partner_profile do
    association :user, factory: :user, role: :partner
    sequence(:name) { |n| "Partner #{n}" }
    status { :active }

    trait :inactive do
      status { :inactive }
    end

    trait :suspended do
      status { :suspended }
    end
  end
end
