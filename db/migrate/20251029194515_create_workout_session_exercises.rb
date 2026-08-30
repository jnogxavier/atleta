class CreateWorkoutSessionExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_session_exercises do |t|
      t.references :workout_session, null: false, foreign_key: true
      t.string :exercise_type, null: false # 'strength', 'mobility', 'core', 'cardio'
      t.bigint :exercise_id, null: false # polymorphic reference to training_*_exercise
      t.boolean :completed, default: false
      t.timestamps
    end

    add_index :workout_session_exercises, [ :workout_session_id, :exercise_type, :exercise_id ], name: 'index_workout_exercises_on_session_and_exercise'
  end
end
