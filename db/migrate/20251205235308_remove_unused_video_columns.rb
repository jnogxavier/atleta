class RemoveUnusedVideoColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :videos, :duration, :string
    remove_column :videos, :category, :string
    remove_column :videos, :title, :string
  end
end
