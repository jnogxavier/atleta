class AddCyclesToWorkoutSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :workout_sessions, :cycles, :jsonb, default: []
    add_column :workout_sessions, :session_notes, :text
  end
end
