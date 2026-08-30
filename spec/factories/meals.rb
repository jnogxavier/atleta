FactoryBot.define do
  factory :meal do
    association :nutrition_plan
    meal_type { "cafe_da_manha" }
    meal_time { "08:00" }
    observations { "Refeição matinal" }
  end
end
