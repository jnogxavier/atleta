require 'rails_helper'

RSpec.describe MealSerializer do
  let(:nutrition_plan) { create(:nutrition_plan) }
  let(:meal) { create(:meal, nutrition_plan: nutrition_plan) }
  let(:food) { create(:food, energy_kcal: 100, protein_g: 10) }

  before do
    create(:meal_food, meal: meal, food: food, quantity_grams: 100)
  end

  describe '#default view' do
    it 'renders without nutrition_data' do
      result = MealSerializer.render(meal, view: :default)
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(meal.id)
      expect(result[:meal_type]).to eq(meal.meal_type)
    end
  end

  describe '#summary view' do
    it 'renders without nutrition_data' do
      result = MealSerializer.render(meal, view: :summary)
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(meal.id)
      expect(result[:meal_type_display]).to be_present
    end
  end

  describe '#detailed view' do
    context 'in development environment' do
      it 'raises ArgumentError when nutrition_data is missing' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))

        expect {
          MealSerializer.render(meal, view: :detailed)
        }.to raise_error(ArgumentError, /nutrition_data/)
      end
    end

    context 'in test environment' do
      it 'raises ArgumentError when nutrition_data is missing' do
        expect {
          MealSerializer.render(meal, view: :detailed)
        }.to raise_error(ArgumentError, /nutrition_data/)
      end
    end

    context 'in production environment' do
      it 'logs warning and uses fallback when nutrition_data is missing' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

        expect(Rails.logger).to receive(:warn).with(/nutrition_data/)

        result = MealSerializer.render(meal, view: :detailed)
        expect(result).to be_a(Hash)
        expect(result[:total_calories]).to be_a(Numeric)
        expect(result[:total_protein]).to be_a(Numeric)
      end
    end

    context 'with precomputed nutrition_data' do
      it 'renders with all nutrition totals' do
        nutrition_data = MealNutritionService.precompute_for_meals([ meal ])

        result = MealSerializer.render(meal, view: :detailed, nutrition_data: nutrition_data)

        expect(result).to be_a(Hash)
        expect(result[:id]).to eq(meal.id)
        expect(result[:total_foods]).to eq(1)
        expect(result[:total_calories]).to be_a(Numeric)
        expect(result[:total_protein]).to be_a(Numeric)
        expect(result[:total_carbohydrates]).to be_a(Numeric)
        expect(result[:total_fat]).to be_a(Numeric)
        expect(result[:meal_foods]).to be_an(Array)
      end

      it 'uses precomputed values from nutrition_data' do
        nutrition_data = MealNutritionService.precompute_for_meals([ meal ])

        result = MealSerializer.render(meal, view: :detailed, nutrition_data: nutrition_data)

        # Verify values match the precomputed data
        expected_nutrition = nutrition_data[meal.id]
        expect(result[:total_calories]).to eq(expected_nutrition.total_calories)
        expect(result[:total_protein]).to eq(expected_nutrition.total_protein)
      end
    end
  end

  describe '#admin view' do
    context 'in development environment' do
      it 'raises ArgumentError when nutrition_data is missing' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))

        expect {
          MealSerializer.render(meal, view: :admin)
        }.to raise_error(ArgumentError, /nutrition_data/)
      end
    end

    context 'in production environment' do
      it 'logs warning and uses fallback when nutrition_data is missing' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

        expect(Rails.logger).to receive(:warn).with(/nutrition_data/)

        result = MealSerializer.render(meal, view: :admin)
        expect(result).to be_a(Hash)
        expect(result[:total_calories]).to be_a(Numeric)
      end
    end

    context 'with precomputed nutrition_data' do
      it 'renders admin view with nutrition totals' do
        nutrition_data = MealNutritionService.precompute_for_meals([ meal ])

        result = MealSerializer.render(meal, view: :admin, nutrition_data: nutrition_data)

        expect(result).to be_a(Hash)
        expect(result[:id]).to eq(meal.id)
        expect(result[:nutrition_plan_id]).to eq(nutrition_plan.id)
        expect(result[:total_foods]).to eq(1)
        expect(result[:total_calories]).to be_a(Numeric)
      end
    end
  end

  describe 'serialization accuracy' do
    it 'calculates nutrition totals correctly with multiple foods' do
      food2 = create(:food, energy_kcal: 200, protein_g: 20)
      create(:meal_food, meal: meal, food: food2, quantity_grams: 100)

      nutrition_data = MealNutritionService.precompute_for_meals([ meal ])
      result = MealSerializer.render(meal, view: :detailed, nutrition_data: nutrition_data)

      # food1: 100 kcal * 100g / 100 = 100 kcal
      # food2: 200 kcal * 100g / 100 = 200 kcal
      # Total: 300 kcal
      expect(result[:total_calories]).to eq(300.0)

      # food1: 10g * 100g / 100 = 10g
      # food2: 20g * 100g / 100 = 20g
      # Total: 30g
      expect(result[:total_protein]).to eq(30.0)

      # Both foods should be counted
      expect(result[:total_foods]).to eq(2)
    end
  end
end
