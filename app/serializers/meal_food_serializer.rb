# frozen_string_literal: true

class MealFoodSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      quantity_grams: object.quantity_grams
    ).merge(
      food_name: object.food.name,
      food_id: object.food_id,
      energy_kcal: object.calculated_energy_kcal
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      quantity_grams: object.quantity_grams
    ).merge(
      food_name: object.food.name,
      food_id: object.food_id
    )
  end

  # Detailed view - full info with food details and nutritional breakdown
  def detailed
    attributes(
      id: object.id,
      quantity_grams: object.quantity_grams,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      food: serialize_association(object.food, FoodSerializer, view: :summary),
      calculated_energy_kcal: object.calculated_energy_kcal,
      calculated_protein_g: object.calculated_protein_g,
      calculated_carbohydrate_g: object.calculated_carbohydrate_g,
      calculated_fat_g: object.calculated_fat_g
    )
  end

  # Admin view - administrative details
  def admin
    attributes(
      id: object.id,
      meal_id: object.meal_id,
      food_id: object.food_id,
      quantity_grams: object.quantity_grams,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      food_name: object.food.name,
      calculated_energy_kcal: object.calculated_energy_kcal,
      calculated_protein_g: object.calculated_protein_g,
      calculated_carbohydrate_g: object.calculated_carbohydrate_g,
      calculated_fat_g: object.calculated_fat_g
    )
  end
end
