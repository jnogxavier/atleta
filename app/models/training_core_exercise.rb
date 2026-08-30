class TrainingCoreExercise < ApplicationRecord
  include TrainingExerciseValidations

  belongs_to :training
  belongs_to :core_exercise

  before_validation :normalize_reps

  validates :reps, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  private

  def normalize_reps
    self.reps = nil if reps.blank?
  end
end
