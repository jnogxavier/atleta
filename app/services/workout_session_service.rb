class WorkoutSessionService
  # Exercise type to training association mapping
  EXERCISE_TYPES = {
    strength: :training_strength_exercises,
    mobility: :training_mobility_exercises,
    core: :training_core_exercises,
    cardio: :training_cardio_exercises
  }.freeze

  def self.initialize_workout_session(student_profile, training)
    new.initialize_workout_session(student_profile, training)
  end

  def self.complete_workout_session(workout_session)
    new.complete_workout_session(workout_session)
  end

  def initialize_workout_session(student_profile, training)
    ActiveRecord::Base.transaction do
      session = student_profile.workout_sessions.create!(training: training)

      # Create workout session exercises for each exercise type
      EXERCISE_TYPES.each do |type, association|
        training.public_send(association).each do |training_exercise|
          session.workout_session_exercises.create!(
            exercise_type: type.to_s,
            exercise_id: training_exercise.id
          )
        end
      end

      session
    end
  rescue => e
    raise WorkoutSessionInitializationError.new("Failed to initialize workout session: #{e.message}", e)
  end

  def complete_workout_session(workout_session)
    return false unless workout_session

    ActiveRecord::Base.transaction do
      workout_session.update!(completed_at: Time.current)
      true
    end
  rescue => e
    raise WorkoutSessionCompletionError.new("Failed to complete workout session: #{e.message}", e)
  end
end

# Custom error classes for workout session operations
class WorkoutSessionInitializationError < StandardError
  attr_reader :original_error

  def initialize(message, original_error = nil)
    super(message)
    @original_error = original_error
  end
end

class WorkoutSessionCompletionError < StandardError
  attr_reader :original_error

  def initialize(message, original_error = nil)
    super(message)
    @original_error = original_error
  end
end
