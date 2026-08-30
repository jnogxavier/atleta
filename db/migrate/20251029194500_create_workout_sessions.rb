class CreateWorkoutSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_sessions do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.references :training, null: false, foreign_key: true
      t.datetime :completed_at
      t.text :notes
      t.timestamps
    end

    add_index :workout_sessions, [ :student_profile_id, :training_id, :completed_at ]
  end
end
