class AddCounterCachesToModels < ActiveRecord::Migration[8.1]
  def change
    # Add counter cache for meals count on nutrition_plans
    add_column :nutrition_plans, :meals_count, :integer, default: 0, null: false

    # Populate existing counts
    NutritionPlan.reset_column_information
    NutritionPlan.find_each { |plan| plan.update_column(:meals_count, plan.meals.count) }
  end
end
