FactoryBot.define do
  factory :nutrition_plan do
    association :student_profile
    sequence(:name) { |n| "Plano Nutricional #{n}" }
    description { "Plano nutricional personalizado" }
    active { true }
  end
end
