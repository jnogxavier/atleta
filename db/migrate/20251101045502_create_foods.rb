class CreateFoods < ActiveRecord::Migration[8.1]
  def change
    create_table :foods do |t|
      t.references :meal, null: false, foreign_key: true
      t.string :nome_do_alimento
      t.string :quantidade
      t.decimal :calorias
      t.decimal :proteina

      t.timestamps
    end
  end
end
