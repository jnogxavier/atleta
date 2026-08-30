class CreateTrainingStrengthExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :training_strength_exercises do |t|
      t.references :training, null: false, foreign_key: true
      t.references :strength_exercise, null: false, foreign_key: true
      t.integer :sets
      t.string :reps
      t.string :rest
      t.text :notes
      t.integer :position
      t.boolean :completed

      t.timestamps
    end
  end
end
