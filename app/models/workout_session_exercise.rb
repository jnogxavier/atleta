class WorkoutSessionExercise < ApplicationRecord
  belongs_to :workout_session

  validates :exercise_type, presence: true, inclusion: { in: %w[strength mobility core cardio] }
  validates :exercise_id, presence: true

  scope :completed_exercises, -> { where(completed: true) }
  scope :pending_exercises, -> { where(completed: false) }

  def training_exercise
    case exercise_type
    when "strength"
      TrainingStrengthExercise.find(exercise_id)
    when "mobility"
      TrainingMobilityExercise.find(exercise_id)
    when "core"
      TrainingCoreExercise.find(exercise_id)
    when "cardio"
      TrainingCardioExercise.find(exercise_id)
    end
  end

  def toggle_completion!
    update(completed: !completed)
  end
end
