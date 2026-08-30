class AddExerciseIdIndexToWorkoutSessionExercises < ActiveRecord::Migration[8.1]
  def change
    # Add index on exercise_id for queries that filter by exercise type
    # This improves performance for lookups like:
    # WorkoutSessionExercise.where(exercise_id: id, exercise_type: type)
    add_index :workout_session_exercises, :exercise_id, if_not_exists: true
  end
end
