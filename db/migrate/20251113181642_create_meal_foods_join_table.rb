class CreateMealFoodsJoinTable < ActiveRecord::Migration[8.1]
  def up
    # Create the join table
    create_table :meal_foods do |t|
      t.references :meal, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.decimal :quantity_grams, precision: 8, scale: 2, null: false

      t.timestamps
    end

    # Add indexes for better query performance
    add_index :meal_foods, [ :meal_id, :food_id ], unique: true

    # Remove meal_id from foods table since we now use the join table
    remove_column :foods, :meal_id
  end

  def down
    # Add meal_id back to foods table
    add_reference :foods, :meal, foreign_key: true

    # Remove the join table
    drop_table :meal_foods
  end
end
