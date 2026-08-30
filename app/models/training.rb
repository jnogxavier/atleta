class Training < ApplicationRecord
  belongs_to :student_profile

  has_many :training_strength_exercises, -> { order(position: :asc) }, dependent: :destroy
  has_many :strength_exercises, through: :training_strength_exercises

  has_many :training_mobility_exercises, -> { order(position: :asc) }, dependent: :destroy
  has_many :mobility_exercises, through: :training_mobility_exercises

  has_many :training_core_exercises, -> { order(position: :asc) }, dependent: :destroy
  has_many :core_exercises, through: :training_core_exercises

  has_many :training_cardio_exercises, -> { order(position: :asc) }, dependent: :destroy
  has_many :cardio_exercises, through: :training_cardio_exercises

  has_many :workout_sessions, dependent: :destroy

  validates :name, presence: true
  validates :day, presence: true

  scope :active_trainings, -> { where(active: true) }

  def total_exercises
    # Single database query instead of 4 separate counts
    [ training_strength_exercises, training_mobility_exercises, training_core_exercises, training_cardio_exercises ]
      .sum(&:size)
  end
end
