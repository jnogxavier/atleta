require 'rails_helper'

describe MealNutritionService do
  describe '.precompute_for_meals' do
    let(:nutrition_plan) { create(:nutrition_plan) }

    it 'returns empty hash for empty meals' do
      result = described_class.precompute_for_meals([])
      expect(result).to eq({})
    end

    it 'precomputes nutrition data for meals with foods' do
      meal = create(:meal, nutrition_plan: nutrition_plan)
      food = create(:food, energy_kcal: 100, protein_g: 10)
      create(:meal_food, meal: meal, food: food, quantity_grams: 100)

      result = described_class.precompute_for_meals([ meal ])
      expect(result).to have_key(meal.id)
      expect(result[meal.id].total_foods).to eq(1)
      expect(result[meal.id].total_calories).to eq(100)
      expect(result[meal.id].total_protein).to eq(10)
    end

    it 'provides default values for empty meals' do
      meal = create(:meal, nutrition_plan: nutrition_plan)

      result = described_class.precompute_for_meals([ meal ])
      nutrition = result[meal.id]

      expect(nutrition.total_foods).to eq(0)
      expect(nutrition.total_calories).to eq(0)
      expect(nutrition.total_protein).to eq(0)
    end

    it 'calculates nutrition for multiple meals' do
      meal1 = create(:meal, nutrition_plan: nutrition_plan)
      meal2 = create(:meal, nutrition_plan: nutrition_plan)
      food = create(:food, energy_kcal: 100, protein_g: 10)

      create(:meal_food, meal: meal1, food: food, quantity_grams: 100)
      create(:meal_food, meal: meal2, food: food, quantity_grams: 50)

      result = described_class.precompute_for_meals([ meal1, meal2 ])

      expect(result[meal1.id].total_calories).to eq(100)
      expect(result[meal2.id].total_calories).to eq(50)
    end

    it 'handles nil nutrition values with COALESCE' do
      meal = create(:meal, nutrition_plan: nutrition_plan)
      food = create(:food, energy_kcal: 100, protein_g: 10, carbohydrate_g: nil, fat_g: nil)
      create(:meal_food, meal: meal, food: food, quantity_grams: 100)

      result = described_class.precompute_for_meals([ meal ])
      nutrition = result[meal.id]

      expect(nutrition.total_carbohydrates).to eq(0)
      expect(nutrition.total_fat).to eq(0)
    end
  end
end
