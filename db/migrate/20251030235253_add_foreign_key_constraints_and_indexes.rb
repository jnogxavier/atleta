class AddForeignKeyConstraintsAndIndexes < ActiveRecord::Migration[8.1]
  def change
    # Add indexes for foreign keys if they don't already exist
    # User associations
    add_index :sessions, :user_id unless index_exists?(:sessions, :user_id)
    add_index :student_profiles, :user_id unless index_exists?(:student_profiles, :user_id)
    add_index :partner_profiles, :user_id unless index_exists?(:partner_profiles, :user_id)
    add_index :anamneses, :user_id unless index_exists?(:anamneses, :user_id)
    add_index :notifications, :user_id unless index_exists?(:notifications, :user_id)
    add_index :evaluation_media, :user_id unless index_exists?(:evaluation_media, :user_id)

    # Training associations
    add_index :trainings, :student_profile_id unless index_exists?(:trainings, :student_profile_id)
    add_index :training_strength_exercises, :training_id unless index_exists?(:training_strength_exercises, :training_id)
    add_index :training_strength_exercises, :strength_exercise_id unless index_exists?(:training_strength_exercises, :strength_exercise_id)
    add_index :training_mobility_exercises, :training_id unless index_exists?(:training_mobility_exercises, :training_id)
    add_index :training_mobility_exercises, :mobility_exercise_id unless index_exists?(:training_mobility_exercises, :mobility_exercise_id)
    add_index :training_core_exercises, :training_id unless index_exists?(:training_core_exercises, :training_id)
    add_index :training_core_exercises, :core_exercise_id unless index_exists?(:training_core_exercises, :core_exercise_id)
    add_index :training_cardio_exercises, :training_id unless index_exists?(:training_cardio_exercises, :training_id)
    add_index :training_cardio_exercises, :cardio_exercise_id unless index_exists?(:training_cardio_exercises, :cardio_exercise_id)

    # Workout session associations
    add_index :workout_sessions, :student_profile_id unless index_exists?(:workout_sessions, :student_profile_id)
    add_index :workout_sessions, :training_id unless index_exists?(:workout_sessions, :training_id)
    add_index :workout_session_exercises, :workout_session_id unless index_exists?(:workout_session_exercises, :workout_session_id)

    # Add foreign key constraints
    # User associations
    add_foreign_key :sessions, :users unless foreign_key_exists?(:sessions, :users)
    add_foreign_key :student_profiles, :users unless foreign_key_exists?(:student_profiles, :users)
    add_foreign_key :partner_profiles, :users unless foreign_key_exists?(:partner_profiles, :users)
    add_foreign_key :anamneses, :users unless foreign_key_exists?(:anamneses, :users)
    add_foreign_key :notifications, :users unless foreign_key_exists?(:notifications, :users)
    add_foreign_key :evaluation_media, :users unless foreign_key_exists?(:evaluation_media, :users)

    # Training associations
    add_foreign_key :trainings, :student_profiles unless foreign_key_exists?(:trainings, :student_profiles)
    add_foreign_key :training_strength_exercises, :trainings unless foreign_key_exists?(:training_strength_exercises, :trainings)
    add_foreign_key :training_strength_exercises, :strength_exercises unless foreign_key_exists?(:training_strength_exercises, :strength_exercises)
    add_foreign_key :training_mobility_exercises, :trainings unless foreign_key_exists?(:training_mobility_exercises, :trainings)
    add_foreign_key :training_mobility_exercises, :mobility_exercises unless foreign_key_exists?(:training_mobility_exercises, :mobility_exercises)
    add_foreign_key :training_core_exercises, :trainings unless foreign_key_exists?(:training_core_exercises, :trainings)
    add_foreign_key :training_core_exercises, :core_exercises unless foreign_key_exists?(:training_core_exercises, :core_exercises)
    add_foreign_key :training_cardio_exercises, :trainings unless foreign_key_exists?(:training_cardio_exercises, :trainings)
    add_foreign_key :training_cardio_exercises, :cardio_exercises unless foreign_key_exists?(:training_cardio_exercises, :cardio_exercises)

    # Workout session associations
    add_foreign_key :workout_sessions, :student_profiles unless foreign_key_exists?(:workout_sessions, :student_profiles)
    add_foreign_key :workout_sessions, :trainings unless foreign_key_exists?(:workout_sessions, :trainings)
    add_foreign_key :workout_session_exercises, :workout_sessions unless foreign_key_exists?(:workout_session_exercises, :workout_sessions)
  end
end
