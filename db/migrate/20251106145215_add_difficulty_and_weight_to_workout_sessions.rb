class AddDifficultyAndWeightToWorkoutSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :workout_sessions, :difficulty, :integer
    add_column :workout_sessions, :weight_used, :decimal
  end
end
