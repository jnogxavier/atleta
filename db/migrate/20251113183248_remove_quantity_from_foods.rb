class RemoveQuantityFromFoods < ActiveRecord::Migration[8.1]
  def up
    remove_column :foods, :quantity
  end

  def down
    add_column :foods, :quantity, :string
  end
end
