class Food < ApplicationRecord
  has_many :meal_foods, dependent: :destroy, inverse_of: :food
  has_many :meals, through: :meal_foods

  validates :name, presence: true
  validates :energy_kcal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :protein_g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :carbohydrate_g, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :fat_g, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :by_category, ->(category) { where(category: category) }

  STANDARD_QUANTITY_GRAMS = 100.0

  def self.categories
    distinct.pluck(:category).compact.sort
  end
end
