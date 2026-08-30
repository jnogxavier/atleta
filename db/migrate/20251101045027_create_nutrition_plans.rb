class CreateNutritionPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :nutrition_plans do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
