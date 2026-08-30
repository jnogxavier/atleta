class TrainingMobilityExercise < ApplicationRecord
  include TrainingExerciseValidations

  belongs_to :training
  belongs_to :mobility_exercise

  before_validation :normalize_duration

  validates :duration, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  private

  def normalize_duration
    self.duration = nil if duration.blank?
  end
end
