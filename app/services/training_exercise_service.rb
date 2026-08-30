# frozen_string_literal: true

class TrainingExerciseService
  def initialize(training)
    raise ArgumentError, "Training must be persisted" unless training.persisted?
    @training = training
  end

  # Add exercises to a training plan
  # @param exercises_params [Hash] Exercises grouped by type
  # @raise [ArgumentError] if validation fails
  def add_exercises(exercises_params)
    ActiveRecord::Base.transaction do
      exercises_params.each do |type, exercises|
        exercises.each_with_index do |(exercise_id, details), index|
          add_exercise(type, exercise_id, details, index)
        end
      end
    end
  end

  # Update exercises (replaces all existing exercises)
  # @param exercises_params [Hash] Exercises grouped by type
  # @raise [ArgumentError] if validation fails
  def update_exercises(exercises_params)
    ActiveRecord::Base.transaction do
      clear_all_exercises
      add_exercises(exercises_params)
    end
  end

  private

  EXERCISE_TYPES = {
    "strength" => :training_strength_exercises,
    "mobility" => :training_mobility_exercises,
    "core" => :training_core_exercises,
    "cardio" => :training_cardio_exercises
  }.freeze

  def add_exercise(type, exercise_id, details, position)
    raise ArgumentError, "Invalid exercise type: #{type}" unless EXERCISE_TYPES.key?(type)

    # Validate exercise exists
    exercise_class = "#{type.capitalize}Exercise".constantize
    exercise = exercise_class.find_by(id: exercise_id)
    raise ActiveRecord::RecordNotFound, "#{exercise_class} not found with ID: #{exercise_id}" unless exercise

    # Validate required fields
    raise ArgumentError, "Sets are required" unless details["sets"].present?

    case type
    when "strength", "core"
      raise ArgumentError, "Reps are required for #{type} exercises" unless details["reps"].present?
      add_strength_or_core_exercise(type, exercise_id, details, position)
    when "mobility"
      raise ArgumentError, "Duration is required for mobility exercises" unless (details["duration"] || details["rest"]).present?
      add_mobility_exercise(exercise_id, details, position)
    when "cardio"
      raise ArgumentError, "Duration is required for cardio exercises" unless (details["duration"] || details["rest"]).present?
      add_cardio_exercise(exercise_id, details, position)
    end
  end

  def add_strength_or_core_exercise(type, exercise_id, details, position)
    association = EXERCISE_TYPES[type]
    @training.send(association).create!(
      "#{type}_exercise_id".to_sym => exercise_id,
      sets: details["sets"],
      reps: ApplicationHelper.parse_integer(details["reps"]),
      rest: ApplicationHelper.parse_integer(details["rest"]),
      notes: details["notes"],
      position: position
    )
  end

  def add_mobility_exercise(exercise_id, details, position)
    @training.training_mobility_exercises.create!(
      mobility_exercise_id: exercise_id,
      duration: ApplicationHelper.parse_integer(details["duration"] || details["rest"]),
      sets: details["sets"],
      notes: details["notes"],
      position: position
    )
  end

  def add_cardio_exercise(exercise_id, details, position)
    @training.training_cardio_exercises.create!(
      cardio_exercise_id: exercise_id,
      duration: ApplicationHelper.parse_integer(details["duration"] || details["rest"]),
      intensity: details["intensity"],
      notes: details["notes"],
      position: position
    )
  end

  def clear_all_exercises
    # Use destroy_all instead of delete_all to trigger callbacks and cascade deletes
    # This ensures dependent associations (like videos) are properly cleaned up
    EXERCISE_TYPES.values.each { |association| @training.send(association).destroy_all }
  end
end
