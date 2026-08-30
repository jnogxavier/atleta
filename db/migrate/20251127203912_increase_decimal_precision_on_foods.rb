class IncreaseDecimalPrecisionOnFoods < ActiveRecord::Migration[8.1]
  def change
    # Remove decimal precision constraints to allow highly precise nutritional data
    # Food data from TACO and similar databases may have many decimal places
    # Frontend will display with 2 decimals, but backend stores full precision
    change_column :foods, :energy_kcal, :decimal, precision: nil
    change_column :foods, :protein_g, :decimal, precision: nil
    change_column :foods, :carbohydrate_g, :decimal, precision: nil
  end
end
