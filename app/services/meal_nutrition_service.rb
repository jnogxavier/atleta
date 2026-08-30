# frozen_string_literal: true

class MealNutritionService
  # Value object for nutrition data returned by precomputation
  NutritionData = Struct.new(
    :meal_id,
    :total_foods,
    :total_calories,
    :total_protein,
    :total_carbohydrates,
    :total_fat,
    keyword_init: true
  ) do
    def initialize(meal_id:, total_foods: 0, total_calories: 0.0,
                   total_protein: 0.0, total_carbohydrates: 0.0, total_fat: 0.0)
      super
    end
  end

  # Precompute nutritional data for meals in a single query
  # This prevents N+1 queries when serializing meals with nutrition totals
  def self.precompute_for_meals(meals)
    return {} if meals.empty?

    meal_ids = meals.map(&:id)
    standard_qty = Food::STANDARD_QUANTITY_GRAMS.to_f

    # Single database query to get all nutrition data at once
    # Calculate products in database, division happens in Ruby to avoid SQL injection patterns
    nutrition_data = MealFood.joins(:food)
                             .where(meal_id: meal_ids)
                             .group(:meal_id)
                             .select(
                               :meal_id,
                               Arel.sql("COUNT(DISTINCT foods.id) AS total_foods"),
                               Arel.sql("SUM(foods.energy_kcal * meal_foods.quantity_grams) AS total_calories_raw"),
                               Arel.sql("SUM(foods.protein_g * meal_foods.quantity_grams) AS total_protein_raw"),
                               Arel.sql("SUM(COALESCE(foods.carbohydrate_g, 0) * meal_foods.quantity_grams) AS total_carbohydrates_raw"),
                               Arel.sql("SUM(COALESCE(foods.fat_g, 0) * meal_foods.quantity_grams) AS total_fat_raw")
                             )
                             .index_by(&:meal_id)

    # Convert to NutritionData structs, divide in Ruby, and provide defaults for meals with no foods
    result = {}
    meal_ids.each do |meal_id|
      if nutrition_data[meal_id]
        row = nutrition_data[meal_id]
        result[meal_id] = NutritionData.new(
          meal_id: meal_id,
          total_foods: row.total_foods || 0,
          total_calories: ((row.total_calories_raw || 0).to_f / standard_qty),
          total_protein: ((row.total_protein_raw || 0).to_f / standard_qty),
          total_carbohydrates: ((row.total_carbohydrates_raw || 0).to_f / standard_qty),
          total_fat: ((row.total_fat_raw || 0).to_f / standard_qty)
        )
      else
        result[meal_id] = NutritionData.new(meal_id: meal_id)
      end
    end

    result
  end
end
