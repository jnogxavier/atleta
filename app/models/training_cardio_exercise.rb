class TrainingCardioExercise < ApplicationRecord
  belongs_to :training
  belongs_to :cardio_exercise

  before_validation :normalize_blank_values

  enum :intensity, {
    low: "low",
    moderate: "moderate",
    high: "high"
  }, prefix: true

  validates :duration, numericality: { greater_than: 0 }, allow_nil: true
  validates :calories, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def total_calories
    calories || 0
  end

  private

  def normalize_blank_values
    self.duration = nil if duration.blank?
    self.calories = nil if calories.blank?
    self.notes = nil if notes.blank?
  end
end
