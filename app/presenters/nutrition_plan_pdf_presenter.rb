class NutritionPlanPdfPresenter
  attr_reader :nutrition_plan, :student_profile, :nutrition_data

  # Initialize presenter with precomputed nutrition data to prevent N+1 queries
  def initialize(nutrition_plan, student_profile, nutrition_data = nil)
    @nutrition_plan = nutrition_plan
    @student_profile = student_profile
    # Precompute nutrition data if not provided to prevent N+1 queries
    @nutrition_data = nutrition_data || MealNutritionService.precompute_for_meals(nutrition_plan.meals)
  end

  def plan_name
    nutrition_plan.name
  end

  def student_name
    student_profile.user.name || student_profile.user.email_address
  end

  def plan_description
    nutrition_plan.description
  end

  # Use precomputed nutrition data for all total calculations
  def total_daily_calories
    nutrition_data.values.sum(&:total_calories).round(1)
  end

  def total_daily_protein
    nutrition_data.values.sum(&:total_protein).round(1)
  end

  def total_daily_carbohydrates
    nutrition_data.values.sum(&:total_carbohydrates).round(1)
  end

  def total_daily_fat
    nutrition_data.values.sum(&:total_fat).round(1)
  end

  def meals_data
    nutrition_plan.meals.map do |meal|
      meal_nutrition = nutrition_data[meal.id]
      {
        type: meal.meal_type_display,
        time: meal.meal_time&.strftime("%H:%M"),
        observations: meal.observations || "-",
        calories: meal_nutrition.total_calories.round(1),
        protein: meal_nutrition.total_protein.round(1),
        foods: meal.meal_foods.map { |mf| food_data(mf) }
      }
    end
  end

  private

  def food_data(meal_food)
    {
      name: meal_food.food.name,
      quantity: meal_food.quantity_grams.round(1),
      energy: meal_food.calculated_energy_kcal.round(1),
      protein: meal_food.calculated_protein_g.round(1),
      carbs: meal_food.calculated_carbohydrate_g&.round(1) || "-",
      fat: meal_food.calculated_fat_g&.round(1) || "-"
    }
  end
end
