FactoryBot.define do
  factory :evaluation_medium do
    association :user
    media_type { "photo" }
    file_url { Faker::Internet.url }
    evaluated { false }

    trait :photo do
      media_type { "photo" }
    end

    trait :video do
      media_type { "video" }
    end

    trait :evaluated do
      evaluated { true }
      admin_notes { Faker::Lorem.paragraph }
    end

    trait :pending do
      evaluated { false }
      admin_notes { nil }
    end
  end
end
