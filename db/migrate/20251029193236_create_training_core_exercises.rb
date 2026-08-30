class CreateTrainingCoreExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :training_core_exercises do |t|
      t.references :training, null: false, foreign_key: true
      t.references :core_exercise, null: false, foreign_key: true
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
