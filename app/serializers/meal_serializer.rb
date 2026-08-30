# frozen_string_literal: true

class MealSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      meal_type: object.meal_type,
      meal_time: object.meal_time
    ).merge(
      meal_type_display: object.meal_type_display
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      meal_type: object.meal_type,
      meal_time: object.meal_time
    ).merge(
      meal_type_display: object.meal_type_display
    )
  end

  # Detailed view - full info with nutritional totals and foods
  # REQUIRES: nutrition_data to be passed via options to prevent N+1 queries
  # Example: MealSerializer.render(meal, view: :detailed, nutrition_data: precomputed_data)
  def detailed
    nutrition_data = options[:nutrition_data]&.dig(object.id)
    log_missing_precomputation_warning(nutrition_data)

    attributes(
      id: object.id,
      meal_type: object.meal_type,
      meal_time: object.meal_time,
      observations: object.observations,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      meal_type_display: object.meal_type_display,
      **compute_nutrition_totals(nutrition_data),
      meal_foods: serialize_collection(object.meal_foods, MealFoodSerializer, view: :detailed)
    )
  end

  # Admin view - administrative details
  # REQUIRES: nutrition_data to be passed via options to prevent N+1 queries
  def admin
    nutrition_data = options[:nutrition_data]&.dig(object.id)
    log_missing_precomputation_warning(nutrition_data)

    attributes(
      id: object.id,
      meal_type: object.meal_type,
      meal_time: object.meal_time,
      observations: object.observations,
      nutrition_plan_id: object.nutrition_plan_id,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      meal_type_display: object.meal_type_display,
      **compute_nutrition_totals(nutrition_data)
    )
  end

  private

  def compute_nutrition_totals(nutrition_data)
    if nutrition_data
      {
        total_foods: nutrition_data.total_foods,
        total_calories: nutrition_data.total_calories,
        total_protein: nutrition_data.total_protein,
        total_carbohydrates: nutrition_data.total_carbohydrates,
        total_fat: nutrition_data.total_fat
      }
    else
      # Fallback for single meal serialization (not in bulk operations)
      {
        total_foods: object.foods.count,
        total_calories: object.total_calories,
        total_protein: object.total_protein,
        total_carbohydrates: object.total_carbohydrates,
        total_fat: object.total_fat
      }
    end
  end

  def log_missing_precomputation_warning(nutrition_data)
    return if nutrition_data.present?

    warning_message = "[PERFORMANCE] MealSerializer##{options[:view] || :detailed} " \
      "rendering without precomputed nutrition_data - N+1 queries will occur. " \
      "Pass nutrition_data: MealNutritionService.precompute_for_meals(meals)"

    if Rails.env.development? || Rails.env.test?
      # Fail fast in development/test to catch missing precomputation early
      raise ArgumentError, warning_message
    else
      # Only log warning in production for backward compatibility
      Rails.logger.warn(warning_message)
    end
  end
end
