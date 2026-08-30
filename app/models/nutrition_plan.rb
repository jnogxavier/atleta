class NutritionPlan < ApplicationRecord
  belongs_to :student_profile
  has_many :meals, -> { order(:meal_time) }, dependent: :destroy

  accepts_nested_attributes_for :meals, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :student_profile, presence: true

  after_initialize :set_defaults, if: :new_record?

  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  def total_meals
    # Use counter cache to avoid COUNT query
    meals_count || meals.count
  end

  def student_name
    return nil unless student_profile_id.present?
    student_profile&.name
  end

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
