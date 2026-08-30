class ModifyFoodsForTacoData < ActiveRecord::Migration[8.1]
  def change
    # Rename Portuguese columns to English
    rename_column :foods, :nome_do_alimento, :name
    rename_column :foods, :quantidade, :quantity
    rename_column :foods, :calorias, :energy_kcal
    rename_column :foods, :proteina, :protein_g

    # Add carbohydrate column
    add_column :foods, :carbohydrate_g, :decimal, precision: 8, scale: 2

    # Make meal_id nullable to support TACO reference data
    change_column_null :foods, :meal_id, true

    # Add category for organizing foods
    add_column :foods, :category, :string

    # Add indexes for better search performance
    add_index :foods, :name
    add_index :foods, :category
  end
end
