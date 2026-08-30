class CardioExercise < ApplicationRecord
  include Exercisable

  validates :cardio_type, length: { maximum: 100 }, allow_blank: true
end
