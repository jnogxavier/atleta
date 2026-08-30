class StrengthExercise < ApplicationRecord
  include Exercisable

  validates :muscle_group, length: { maximum: 100 }, allow_blank: true
  validates :equipment, length: { maximum: 100 }, allow_blank: true
end
