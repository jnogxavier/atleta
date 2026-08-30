# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_14_020812) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.text "notes"
    t.string "target_type"
    t.bigint "target_user_id"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.index ["action", "created_at"], name: "index_admin_audit_logs_on_action_and_created_at"
    t.index ["admin_id", "created_at"], name: "index_admin_audit_logs_on_admin_id_and_created_at"
    t.index ["admin_id"], name: "index_admin_audit_logs_on_admin_id"
    t.index ["created_at"], name: "index_admin_audit_logs_on_created_at"
    t.index ["target_user_id", "created_at"], name: "index_admin_audit_logs_on_target_user_id_and_created_at"
    t.index ["target_user_id"], name: "index_admin_audit_logs_on_target_user_id"
  end

  create_table "anamneses", force: :cascade do |t|
    t.string "address"
    t.text "afternoon_snack"
    t.string "afternoon_snack_time"
    t.integer "age"
    t.string "alcohol_consumption"
    t.text "available_equipment"
    t.date "birth_date"
    t.string "bowel_movement_scale"
    t.text "breakfast"
    t.string "breakfast_time"
    t.string "chewing"
    t.string "cpf"
    t.datetime "created_at", null: false
    t.text "dietary_restrictions"
    t.string "digestion"
    t.text "dinner"
    t.string "dinner_time"
    t.text "eating_motivation"
    t.text "expectations"
    t.boolean "gastritis"
    t.string "gender"
    t.string "goal"
    t.text "health_conditions"
    t.boolean "heartburn"
    t.decimal "height"
    t.text "injuries"
    t.text "lunch"
    t.string "lunch_time"
    t.string "marital_status"
    t.text "medications"
    t.text "personality"
    t.string "phone"
    t.string "physical_activity_level"
    t.string "profession"
    t.boolean "reflux"
    t.text "routine_description"
    t.string "satisfied_with_meals"
    t.integer "sleep_hours"
    t.string "sleep_time"
    t.boolean "smoking"
    t.boolean "snacks_between_meals"
    t.string "stress_level"
    t.string "time_of_biggest_appetite"
    t.string "training_availability"
    t.string "training_location"
    t.datetime "updated_at", null: false
    t.string "urine_scale"
    t.bigint "user_id", null: false
    t.string "wake_up_time"
    t.decimal "weight"
    t.index ["user_id", "created_at"], name: "idx_anamneses_user_created_at"
    t.index ["user_id"], name: "index_anamneses_on_user_id"
  end

  create_table "audio_recordings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_audio_recordings_user_created"
    t.index ["user_id"], name: "index_audio_recordings_on_user_id"
  end

  create_table "cardio_exercises", force: :cascade do |t|
    t.string "cardio_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "video_url"
  end

  create_table "core_exercises", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "video_url"
  end

  create_table "evaluation_media", force: :cascade do |t|
    t.text "admin_notes"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "evaluated", default: false
    t.string "file_name"
    t.integer "file_size"
    t.string "file_url"
    t.string "media_type", null: false
    t.datetime "updated_at", null: false
    t.datetime "uploaded_at"
    t.bigint "user_id", null: false
    t.index ["evaluated", "media_type"], name: "index_evaluation_media_on_evaluated_and_media_type"
    t.index ["evaluated"], name: "index_evaluation_media_on_evaluated"
    t.index ["user_id", "created_at"], name: "index_evaluation_media_on_user_id_and_created_at"
    t.index ["user_id", "uploaded_at"], name: "idx_evaluation_media_user_uploaded"
    t.index ["user_id"], name: "index_evaluation_media_on_user_id"
  end

  create_table "foods", force: :cascade do |t|
    t.decimal "carbohydrate_g"
    t.string "category"
    t.datetime "created_at", null: false
    t.decimal "energy_kcal", null: false
    t.decimal "fat_g"
    t.string "name", null: false
    t.decimal "protein_g", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_foods_on_category"
    t.index ["name"], name: "index_foods_on_name"
  end

  create_table "meal_foods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "food_id", null: false
    t.bigint "meal_id", null: false
    t.decimal "quantity_grams", precision: 8, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["food_id"], name: "idx_meal_foods_food_id"
    t.index ["food_id"], name: "index_meal_foods_on_food_id"
    t.index ["meal_id", "created_at"], name: "idx_meal_foods_meal_created_at"
    t.index ["meal_id", "food_id"], name: "index_meal_foods_on_meal_id_and_food_id", unique: true
    t.index ["meal_id"], name: "index_meal_foods_on_meal_id"
  end

  create_table "meals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.time "meal_time"
    t.string "meal_type"
    t.bigint "nutrition_plan_id", null: false
    t.text "observations"
    t.datetime "updated_at", null: false
    t.index ["nutrition_plan_id", "meal_time"], name: "idx_meals_nutrition_plan_meal_time"
    t.index ["nutrition_plan_id", "meal_type"], name: "idx_meals_nutrition_plan_meal_type"
    t.index ["nutrition_plan_id"], name: "index_meals_on_nutrition_plan_id"
  end

  create_table "mobility_exercises", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "region"
    t.datetime "updated_at", null: false
    t.string "video_url"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action_url"
    t.datetime "created_at", null: false
    t.text "message"
    t.jsonb "metadata"
    t.string "notification_type"
    t.datetime "read_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["metadata"], name: "index_notifications_on_metadata", using: :gin
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id", "created_at"], name: "idx_notifications_user_created_at"
    t.index ["user_id", "read_at"], name: "idx_notifications_user_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "nutrition_plans", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "meals_count", default: 0, null: false
    t.string "name"
    t.bigint "student_profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "student_profile_id"], name: "idx_nutrition_plans_active_student"
    t.index ["student_profile_id"], name: "index_nutrition_plans_on_student_profile_id"
  end

  create_table "partner_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "partner_id"
    t.string "profession"
    t.string "specialty"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["partner_id"], name: "index_partner_profiles_on_partner_id", unique: true
    t.index ["user_id", "status"], name: "idx_partner_profiles_user_status"
    t.index ["user_id"], name: "index_partner_profiles_on_user_id"
  end

  create_table "pending_registrations", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "phone", null: false
    t.datetime "rejected_at"
    t.bigint "rejected_by_id"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_pending_registrations_on_approved_by_id"
    t.index ["email"], name: "index_pending_registrations_on_email", unique: true
    t.index ["rejected_by_id"], name: "index_pending_registrations_on_rejected_by_id"
    t.index ["status", "created_at"], name: "idx_pending_registrations_status_created"
    t.index ["status"], name: "index_pending_registrations_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P30D'::interval)" }, null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["user_id", "created_at"], name: "index_sessions_on_user_id_and_created_at"
    t.index ["user_id", "expires_at"], name: "idx_sessions_user_expires_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "strength_exercises", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "equipment"
    t.string "muscle_group"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "video_url"
  end

  create_table "student_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_at"
    t.string "gender"
    t.string "name"
    t.string "plan"
    t.boolean "rejected", default: false, null: false
    t.datetime "rejected_at"
    t.text "rejection_reason"
    t.date "start_date"
    t.string "status", default: "active"
    t.string "student_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "value", precision: 10, scale: 2, default: "0.0"
    t.index ["created_at"], name: "idx_student_profiles_created_at"
    t.index ["rejected", "status"], name: "idx_student_profiles_rejected_status"
    t.index ["student_id"], name: "index_student_profiles_on_student_id", unique: true
    t.index ["user_id", "status"], name: "idx_student_profiles_user_status"
    t.index ["user_id"], name: "index_student_profiles_on_user_id"
  end

  create_table "training_cardio_exercises", force: :cascade do |t|
    t.integer "calories"
    t.bigint "cardio_exercise_id", null: false
    t.datetime "created_at", null: false
    t.integer "duration"
    t.string "intensity", default: "moderate"
    t.text "notes"
    t.integer "position"
    t.bigint "training_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cardio_exercise_id"], name: "idx_training_cardio_exercises_exercise_id"
    t.index ["cardio_exercise_id"], name: "index_training_cardio_exercises_on_cardio_exercise_id"
    t.index ["training_id", "position"], name: "idx_training_cardio_exercises_training_position"
    t.index ["training_id", "position"], name: "index_training_cardio_exercises_on_training_id_and_position"
    t.index ["training_id"], name: "index_training_cardio_exercises_on_training_id"
  end

  create_table "training_core_exercises", force: :cascade do |t|
    t.bigint "core_exercise_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.integer "position"
    t.string "reps"
    t.string "rest"
    t.integer "sets"
    t.bigint "training_id", null: false
    t.datetime "updated_at", null: false
    t.index ["core_exercise_id"], name: "idx_training_core_exercises_exercise_id"
    t.index ["core_exercise_id"], name: "index_training_core_exercises_on_core_exercise_id"
    t.index ["training_id", "position"], name: "idx_training_core_exercises_training_position"
    t.index ["training_id"], name: "index_training_core_exercises_on_training_id"
  end

  create_table "training_mobility_exercises", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "duration"
    t.string "hold"
    t.bigint "mobility_exercise_id", null: false
    t.text "notes"
    t.integer "position"
    t.integer "sets"
    t.bigint "training_id", null: false
    t.datetime "updated_at", null: false
    t.index ["mobility_exercise_id"], name: "idx_training_mobility_exercises_exercise_id"
    t.index ["mobility_exercise_id"], name: "index_training_mobility_exercises_on_mobility_exercise_id"
    t.index ["training_id", "position"], name: "idx_training_mobility_exercises_training_position"
    t.index ["training_id"], name: "index_training_mobility_exercises_on_training_id"
  end

  create_table "training_strength_exercises", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.integer "position"
    t.string "reps"
    t.string "rest"
    t.integer "sets"
    t.bigint "strength_exercise_id", null: false
    t.bigint "training_id", null: false
    t.datetime "updated_at", null: false
    t.index ["strength_exercise_id"], name: "idx_training_strength_exercises_exercise_id"
    t.index ["strength_exercise_id"], name: "index_training_strength_exercises_on_strength_exercise_id"
    t.index ["training_id", "position"], name: "idx_training_strength_exercises_training_position"
    t.index ["training_id"], name: "index_training_strength_exercises_on_training_id"
  end

  create_table "trainings", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "day"
    t.text "description"
    t.string "name"
    t.text "notes"
    t.bigint "student_profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "student_profile_id"], name: "idx_trainings_active_student"
    t.index ["active"], name: "index_trainings_on_active"
    t.index ["student_profile_id"], name: "index_trainings_on_student_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "activated_at"
    t.integer "activated_by_id"
    t.text "activation_reason"
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.integer "deactivated_by_id"
    t.text "deactivation_reason"
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "password_expires_at"
    t.integer "registration_status", default: 0, null: false
    t.integer "role", default: 1, null: false
    t.boolean "terms_accepted", default: false, null: false
    t.datetime "updated_at", null: false
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email_address", unique: true
    t.index ["created_at"], name: "idx_users_created_at"
    t.index ["deactivated_at", "role"], name: "idx_users_deactivated_role"
    t.index ["email_address", "registration_status"], name: "idx_users_email_registration_status"
    t.index ["registration_status"], name: "index_users_on_registration_status"
  end

  create_table "videos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "thumbnail_url"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "videoable_id", null: false
    t.string "videoable_type", null: false
    t.index ["videoable_type", "videoable_id"], name: "index_videos_on_videoable"
  end

  create_table "workout_session_exercises", force: :cascade do |t|
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.bigint "exercise_id", null: false
    t.string "exercise_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "workout_session_id", null: false
    t.index ["exercise_id"], name: "index_workout_session_exercises_on_exercise_id"
    t.index ["workout_session_id", "exercise_type", "exercise_id"], name: "index_workout_exercises_on_session_and_exercise"
    t.index ["workout_session_id"], name: "index_workout_session_exercises_on_workout_session_id"
  end

  create_table "workout_sessions", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "cycles", default: []
    t.integer "difficulty"
    t.text "notes"
    t.text "session_notes"
    t.bigint "student_profile_id", null: false
    t.bigint "training_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight_used"
    t.index ["student_profile_id", "completed_at"], name: "idx_workout_sessions_student_completed_at"
    t.index ["student_profile_id", "training_id", "completed_at"], name: "idx_on_student_profile_id_training_id_completed_at_6370fdcc89"
    t.index ["student_profile_id"], name: "index_workout_sessions_on_student_profile_id"
    t.index ["training_id"], name: "index_workout_sessions_on_training_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_audit_logs", "users", column: "admin_id"
  add_foreign_key "admin_audit_logs", "users", column: "target_user_id"
  add_foreign_key "anamneses", "users"
  add_foreign_key "audio_recordings", "users"
  add_foreign_key "evaluation_media", "users"
  add_foreign_key "meal_foods", "foods"
  add_foreign_key "meal_foods", "meals"
  add_foreign_key "meals", "nutrition_plans"
  add_foreign_key "notifications", "users"
  add_foreign_key "nutrition_plans", "student_profiles"
  add_foreign_key "partner_profiles", "users"
  add_foreign_key "pending_registrations", "users", column: "approved_by_id"
  add_foreign_key "pending_registrations", "users", column: "rejected_by_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "student_profiles", "users"
  add_foreign_key "training_cardio_exercises", "cardio_exercises"
  add_foreign_key "training_cardio_exercises", "trainings"
  add_foreign_key "training_core_exercises", "core_exercises"
  add_foreign_key "training_core_exercises", "trainings"
  add_foreign_key "training_mobility_exercises", "mobility_exercises"
  add_foreign_key "training_mobility_exercises", "trainings"
  add_foreign_key "training_strength_exercises", "strength_exercises"
  add_foreign_key "training_strength_exercises", "trainings"
  add_foreign_key "trainings", "student_profiles"
  add_foreign_key "workout_session_exercises", "workout_sessions"
  add_foreign_key "workout_sessions", "student_profiles"
  add_foreign_key "workout_sessions", "trainings"
end
