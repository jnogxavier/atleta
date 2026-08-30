FactoryBot.define do
  factory :video do
    url { "https://www.youtube.com/watch?v=#{Faker::Alphanumeric.alphanumeric(number: 11)}" }
    association :videoable, factory: :strength_exercise

    trait :for_strength do
      association :videoable, factory: :strength_exercise
    end

    trait :for_cardio do
      association :videoable, factory: :cardio_exercise
    end

    trait :for_core do
      association :videoable, factory: :core_exercise
    end

    trait :for_mobility do
      association :videoable, factory: :mobility_exercise
    end
  end
end
