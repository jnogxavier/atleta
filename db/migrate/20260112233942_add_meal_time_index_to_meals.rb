class AddMealTimeIndexToMeals < ActiveRecord::Migration[8.1]
  def change
    # Composite index optimizes default ordering by meal_time within a nutrition plan
    # Supports both filtering by nutrition_plan_id and ordering by meal_time efficiently
    # This index is critical now that has_many :meals uses default -> { order(:meal_time) }
    add_index :meals, [ :nutrition_plan_id, :meal_time ],
              name: "idx_meals_nutrition_plan_meal_time"
  end
end
