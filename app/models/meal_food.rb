class MealFood < ApplicationRecord
  belongs_to :meal, inverse_of: :meal_foods
  belongs_to :food, inverse_of: :meal_foods

  validates :food_id, presence: true
  validates :quantity_grams, presence: true, numericality: { greater_than: 0, allow_nil: true }
  validates :food_id, uniqueness: { scope: :meal_id, message: "já foi adicionado a esta refeição" }

  def calculated_energy_kcal
    return 0 unless food && quantity_grams
    food.energy_kcal * (quantity_grams / Food::STANDARD_QUANTITY_GRAMS)
  end

  def calculated_protein_g
    return 0 unless food && quantity_grams
    food.protein_g * (quantity_grams / Food::STANDARD_QUANTITY_GRAMS)
  end

  def calculated_carbohydrate_g
    return 0 unless food && quantity_grams
    return 0 unless food.carbohydrate_g
    food.carbohydrate_g * (quantity_grams / Food::STANDARD_QUANTITY_GRAMS)
  end

  def calculated_fat_g
    return 0 unless food && quantity_grams
    return 0 unless food.fat_g
    food.fat_g * (quantity_grams / Food::STANDARD_QUANTITY_GRAMS)
  end
end
