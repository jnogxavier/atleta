class CreateTrainings < ActiveRecord::Migration[8.1]
  def change
    create_table :trainings do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.string :name
      t.string :day
      t.text :description
      t.boolean :active

      t.timestamps
    end
    add_index :trainings, :active
  end
end
