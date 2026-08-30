class CreateTrainingCardioExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :training_cardio_exercises do |t|
      t.references :training, null: false, foreign_key: true
      t.references :cardio_exercise, null: false, foreign_key: true
      t.integer :duration # in minutes
      t.string :intensity, default: 'moderate' # low, moderate, high
      t.integer :calories
      t.text :notes
      t.integer :position
      t.boolean :completed, default: false

      t.timestamps
    end

    add_index :training_cardio_exercises, [ :training_id, :position ]
  end
end
