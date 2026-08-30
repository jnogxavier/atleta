class AddFatToFoods < ActiveRecord::Migration[8.1]
  def change
    add_column :foods, :fat_g, :decimal
  end
end
