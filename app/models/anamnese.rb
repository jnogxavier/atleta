class Anamnese < ApplicationRecord
  # Maximum string lengths (per-field limits asserted by the Anamnese spec)
  MAX_LONG_TEXT = 2000
  MAX_MEDIUM_TEXT = 1000
  MAX_SHORT_TEXT = 500
  MAX_NOTE = 200
  MAX_PROFESSION = 100
  MAX_SCALE = 50
  MAX_PHONE = 20
  MAX_CPF = 14
  MAX_TIME_STR = 10

  belongs_to :user, required: true

  attr_accessor :skip_audio_validation

  # Required fields for all steps
  validates :gender, presence: true, inclusion: { in: %w[male female] }
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 120 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :goal, :physical_activity_level, :profession, :training_availability, :training_location, :available_equipment, presence: true

  validates :sleep_hours, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24 }
  validates :wake_up_time, :sleep_time, :time_of_biggest_appetite, :alcohol_consumption, :stress_level, presence: true
  validates :breakfast, :lunch, :afternoon_snack, :dinner, presence: true
  validates :breakfast_time, :lunch_time, :afternoon_snack_time, :dinner_time, presence: true
  validates :digestion, :chewing, :eating_motivation, :personality, :satisfied_with_meals, :bowel_movement_scale, :urine_scale, presence: true
  validates :cpf, presence: true, cpf: true
  validates :phone, presence: true, phone: true
  validates :address, presence: true

  # Boolean fields
  validates :smoking, :heartburn, :reflux, :gastritis, :snacks_between_meals, inclusion: { in: [ true, false ], message: "deve ser selecionado" }

  # Length constraints - maxima match the Anamnese spec contract
  validates :personality, :expectations, length: { maximum: MAX_LONG_TEXT }, allow_blank: true
  validates :health_conditions, :available_equipment, :eating_motivation, length: { maximum: MAX_MEDIUM_TEXT }, allow_blank: true
  validates :breakfast, :lunch, :afternoon_snack, :dinner,
            :medications, :injuries, :dietary_restrictions, length: { maximum: MAX_SHORT_TEXT }, allow_blank: true
  validates :address, :training_availability, :training_location,
            :digestion, :chewing, :satisfied_with_meals, length: { maximum: MAX_NOTE }, allow_blank: true
  validates :profession, length: { maximum: MAX_PROFESSION }, allow_blank: true
  validates :time_of_biggest_appetite, :alcohol_consumption, :bowel_movement_scale,
            :urine_scale, :marital_status, :stress_level, length: { maximum: MAX_SCALE }, allow_blank: true
  validates :phone, length: { maximum: MAX_PHONE }, allow_blank: true
  validates :cpf, length: { maximum: MAX_CPF }, allow_blank: true
  validates :wake_up_time, :sleep_time, :breakfast_time, :lunch_time,
            :afternoon_snack_time, :dinner_time, length: { maximum: MAX_TIME_STR }, allow_blank: true

  # Custom validation
  validate :routine_audio_or_text_present, unless: :skip_audio_validation

  private

  def routine_audio_or_text_present
    audio_exists = user&.audio_recording&.file&.attached?
    text_present = routine_description.present?

    unless audio_exists || text_present
      errors.add(:base, "Você deve fornecer uma descrição de rotina ou um áudio")
    end
  end
end
