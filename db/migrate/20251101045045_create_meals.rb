class CreateMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :meals do |t|
      t.references :nutrition_plan, null: false, foreign_key: true
      t.string :meal_type
      t.time :meal_time
      t.text :observations

      t.timestamps
    end
  end
end
