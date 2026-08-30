class Meal < ApplicationRecord
  belongs_to :nutrition_plan, counter_cache: true
  has_many :meal_foods, dependent: :destroy, inverse_of: :meal
  has_many :foods, through: :meal_foods

  accepts_nested_attributes_for :meal_foods, allow_destroy: true, reject_if: :all_blank

  enum :meal_type, {
    cafe_da_manha: "cafe_da_manha",
    lanche: "lanche",
    almoco: "almoco",
    cafe_da_tarde: "cafe_da_tarde",
    jantar: "jantar",
    ceia: "ceia"
  }, validate: true

  validates :meal_type, presence: true
  validates :meal_time, presence: true

  scope :by_time, -> { order(:meal_time) }

  def total_calories
    # Database-level aggregation with division in Ruby to avoid SQL injection patterns
    # Calculate total at database level, then divide by standard quantity in Ruby
    standard_qty = Food::STANDARD_QUANTITY_GRAMS.to_f
    total = meal_foods.joins(:food).sum(
      Arel.sql("foods.energy_kcal * meal_foods.quantity_grams")
    ).to_f
    total / standard_qty
  end

  def total_protein
    # Database-level aggregation: SUM(food.protein_g * meal_food.quantity_grams) / 100
    standard_qty = Food::STANDARD_QUANTITY_GRAMS.to_f
    total = meal_foods.joins(:food).sum(
      Arel.sql("foods.protein_g * meal_foods.quantity_grams")
    ).to_f
    total / standard_qty
  end

  def total_carbohydrates
    # Database-level aggregation with COALESCE for nil values
    standard_qty = Food::STANDARD_QUANTITY_GRAMS.to_f
    total = meal_foods.joins(:food).sum(
      Arel.sql("COALESCE(foods.carbohydrate_g, 0) * meal_foods.quantity_grams")
    ).to_f
    total / standard_qty
  end

  def total_fat
    # Database-level aggregation with COALESCE for nil values
    standard_qty = Food::STANDARD_QUANTITY_GRAMS.to_f
    total = meal_foods.joins(:food).sum(
      Arel.sql("COALESCE(foods.fat_g, 0) * meal_foods.quantity_grams")
    ).to_f
    total / standard_qty
  end

  def meal_type_display
    I18n.t("activerecord.attributes.meal.meal_types.#{meal_type}")
  end
end
