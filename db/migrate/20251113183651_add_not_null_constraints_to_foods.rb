class AddNotNullConstraintsToFoods < ActiveRecord::Migration[8.1]
  def up
    change_column_null :foods, :name, false
    change_column_null :foods, :energy_kcal, false
    change_column_null :foods, :protein_g, false
  end

  def down
    change_column_null :foods, :name, true
    change_column_null :foods, :energy_kcal, true
    change_column_null :foods, :protein_g, true
  end
end
