class CreateAnamneses < ActiveRecord::Migration[8.1]
  def change
    create_table :anamneses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :age
      t.decimal :height
      t.decimal :weight
      t.string :goal
      t.string :physical_activity_level
      t.text :health_conditions
      t.text :medications
      t.text :injuries
      t.text :dietary_restrictions
      t.integer :sleep_hours
      t.string :stress_level
      t.boolean :smoking
      t.string :alcohol_consumption
      t.string :gender

      t.timestamps
    end
  end
end
