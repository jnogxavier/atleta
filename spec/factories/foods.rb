FactoryBot.define do
  factory :food do
    sequence(:name) { |n| "Alimento #{n}" }
    energy_kcal { 100 }
    protein_g { 10 }
    carbohydrate_g { 15 }
    category { "Frutas" }
  end
end
