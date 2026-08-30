FactoryBot.define do
  factory :meal_food do
    association :meal
    association :food
    quantity_grams { 100 }
  end
end
