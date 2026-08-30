# frozen_string_literal: true

class AddMissingPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # HIGH PRIORITY INDEXES - Critical for dashboard and search performance

    # Student filtering and search optimization
    add_index :student_profiles, [ :rejected, :status ],
              name: "idx_student_profiles_rejected_status"

    # Active nutrition plan queries scoped by student
    add_index :nutrition_plans, [ :active, :student_profile_id ],
              name: "idx_nutrition_plans_active_student"

    # Active training queries scoped by student
    add_index :trainings, [ :active, :student_profile_id ],
              name: "idx_trainings_active_student"

    # User status and role filtering
    add_index :users, [ :deactivated_at, :role ],
              name: "idx_users_deactivated_role"

    # Pending registration status and date filtering
    add_index :pending_registrations, [ :status, :created_at ],
              name: "idx_pending_registrations_status_created"

    # Evaluation media filtering by user and sort by upload date
    add_index :evaluation_media, [ :user_id, :uploaded_at ],
              name: "idx_evaluation_media_user_uploaded"

    # Audio recording queries with user and creation date
    add_index :audio_recordings, [ :user_id, :created_at ],
              name: "idx_audio_recordings_user_created"

    # MEDIUM PRIORITY INDEXES - Important for filtering and relationships

    # User registration status filtering
    add_index :users, [ :email_address, :registration_status ],
              name: "idx_users_email_registration_status"

    # Notification read status by user
    add_index :notifications, [ :user_id, :read_at ],
              name: "idx_notifications_user_read_at"

    # Notification ordering and pagination by user
    add_index :notifications, [ :user_id, :created_at ],
              name: "idx_notifications_user_created_at"

    # Student profile scoped by user and status
    add_index :student_profiles, [ :user_id, :status ],
              name: "idx_student_profiles_user_status"

    # Partner profile scoped by user and status
    add_index :partner_profiles, [ :user_id, :status ],
              name: "idx_partner_profiles_user_status"

    # Workout session filtering by completion status
    add_index :workout_sessions, [ :student_profile_id, :completed_at ],
              name: "idx_workout_sessions_student_completed_at"

    # Meal organization by type within nutrition plan
    add_index :meals, [ :nutrition_plan_id, :meal_type ],
              name: "idx_meals_nutrition_plan_meal_type"

    # Meal food ordering for nutritional calculations
    add_index :meal_foods, [ :meal_id, :created_at ],
              name: "idx_meal_foods_meal_created_at"

    # LOW PRIORITY INDEXES - Optional performance enhancements

    # User registration date sorting
    add_index :users, :created_at,
              name: "idx_users_created_at"

    # Session expiration cleanup queries
    add_index :sessions, [ :user_id, :expires_at ],
              name: "idx_sessions_user_expires_at"

    # Anamnese history by user
    add_index :anamneses, [ :user_id, :created_at ],
              name: "idx_anamneses_user_created_at"

    # Student profile creation date sorting
    add_index :student_profiles, :created_at,
              name: "idx_student_profiles_created_at"

    # FOREIGN KEY INDEXES - Composite indexes for common query patterns

    # Training exercise join tables with position ordering
    add_index :training_strength_exercises, [ :training_id, :position ],
              name: "idx_training_strength_exercises_training_position"

    add_index :training_mobility_exercises, [ :training_id, :position ],
              name: "idx_training_mobility_exercises_training_position"

    add_index :training_core_exercises, [ :training_id, :position ],
              name: "idx_training_core_exercises_training_position"

    add_index :training_cardio_exercises, [ :training_id, :position ],
              name: "idx_training_cardio_exercises_training_position"

    # Foreign keys for exercise lookups
    add_index :training_strength_exercises, :strength_exercise_id,
              name: "idx_training_strength_exercises_exercise_id"

    add_index :training_mobility_exercises, :mobility_exercise_id,
              name: "idx_training_mobility_exercises_exercise_id"

    add_index :training_core_exercises, :core_exercise_id,
              name: "idx_training_core_exercises_exercise_id"

    add_index :training_cardio_exercises, :cardio_exercise_id,
              name: "idx_training_cardio_exercises_exercise_id"

    # Nutrition/meal lookups
    add_index :meal_foods, :food_id,
              name: "idx_meal_foods_food_id"
  end
end
