class CreateTrainingMobilityExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :training_mobility_exercises do |t|
      t.references :training, null: false, foreign_key: true
      t.references :mobility_exercise, null: false, foreign_key: true
      t.integer :sets
      t.string :duration
      t.string :hold
      t.text :notes
      t.integer :position
      t.boolean :completed

      t.timestamps
    end
  end
end
