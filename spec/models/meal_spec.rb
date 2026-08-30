require 'rails_helper'

RSpec.describe Meal, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:nutrition_plan) }
    it { is_expected.to have_many(:meal_foods).dependent(:destroy) }
    it { is_expected.to have_many(:foods).through(:meal_foods) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:meal_type) }
    it { is_expected.to validate_presence_of(:meal_time) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:meal_foods).allow_destroy(true) }
  end

  describe 'enum: meal_type' do
    it 'defines meal types' do
      expect(Meal.meal_types.keys).to include(
        'cafe_da_manha', 'lanche', 'almoco', 'jantar', 'ceia'
      )
    end

    it 'validates meal_type from enum' do
      meal = build(:meal, meal_type: 'cafe_da_manha')
      expect(meal).to be_valid
    end

    it 'rejects invalid meal_type' do
      meal = build(:meal, meal_type: 'invalid_type')
      expect(meal).not_to be_valid
    end
  end

  describe 'scopes' do
    let(:nutrition_plan) { create(:nutrition_plan) }
    let!(:morning_meal) { create(:meal, nutrition_plan: nutrition_plan, meal_type: 'cafe_da_manha', meal_time: Time.zone.parse('2025-01-01 08:00')) }
    let!(:lunch_meal) { create(:meal, nutrition_plan: nutrition_plan, meal_type: 'almoco', meal_time: Time.zone.parse('2025-01-01 12:30')) }
    let!(:dinner_meal) { create(:meal, nutrition_plan: nutrition_plan, meal_type: 'jantar', meal_time: Time.zone.parse('2025-01-01 19:00')) }

    describe '.by_time' do
      it 'returns meals ordered by meal_time' do
        meals = Meal.by_time
        expect(meals.map { |m| m.meal_time.strftime('%H:%M') }).to eq([ '08:00', '12:30', '19:00' ])
      end
    end
  end

  describe '#total_calories' do
    let(:nutrition_plan) { create(:nutrition_plan) }
    let(:meal) { create(:meal, nutrition_plan: nutrition_plan) }
    let(:food1) { create(:food, energy_kcal: 100) }
    let(:food2) { create(:food, energy_kcal: 150) }

    it 'calculates total calories from meal foods' do
      create(:meal_food, meal: meal, food: food1, quantity_grams: 100)
      create(:meal_food, meal: meal, food: food2, quantity_grams: 100)

      # Total should be (100 * 100 / 100) + (150 * 100 / 100) = 250
      expect(meal.total_calories).to eq(250)
    end

    it 'returns 0 when meal has no foods' do
      expect(meal.total_calories).to eq(0)
    end
  end

  describe '#total_protein' do
    let(:nutrition_plan) { create(:nutrition_plan) }
    let(:meal) { create(:meal, nutrition_plan: nutrition_plan) }
    let(:food1) { create(:food, protein_g: 10) }
    let(:food2) { create(:food, protein_g: 20) }

    it 'calculates total protein from meal foods' do
      create(:meal_food, meal: meal, food: food1, quantity_grams: 100)
      create(:meal_food, meal: meal, food: food2, quantity_grams: 100)

      # Total should be (10 * 100 / 100) + (20 * 100 / 100) = 30
      expect(meal.total_protein).to eq(30)
    end

    it 'returns 0 when meal has no foods' do
      expect(meal.total_protein).to eq(0)
    end
  end

  describe '#total_carbohydrates' do
    let(:nutrition_plan) { create(:nutrition_plan) }
    let(:meal) { create(:meal, nutrition_plan: nutrition_plan) }
    let(:food1) { create(:food, carbohydrate_g: 50) }
    let(:food2) { create(:food, carbohydrate_g: 75) }

    it 'calculates total carbohydrates from meal foods' do
      create(:meal_food, meal: meal, food: food1, quantity_grams: 100)
      create(:meal_food, meal: meal, food: food2, quantity_grams: 100)

      # Total should be (50 * 100 / 100) + (75 * 100 / 100) = 125
      expect(meal.total_carbohydrates).to eq(125)
    end

    it 'returns 0 when meal has no foods' do
      expect(meal.total_carbohydrates).to eq(0)
    end
  end

  describe '#meal_type_display' do
    let(:nutrition_plan) { create(:nutrition_plan) }

    it 'returns localized meal type name' do
      meal = create(:meal, nutrition_plan: nutrition_plan, meal_type: 'cafe_da_manha')
      # This will use i18n, so we check it returns a string
      expect(meal.meal_type_display).to be_a(String)
    end

    it 'handles all meal types' do
      Meal.meal_types.keys.each do |meal_type|
        meal = create(:meal, nutrition_plan: nutrition_plan, meal_type: meal_type)
        expect(meal.meal_type_display).to be_a(String)
        expect(meal.meal_type_display).not_to be_empty
      end
    end
  end

  describe 'factory' do
    it 'creates a valid meal with factory' do
      meal = create(:meal)
      expect(meal).to be_valid
      expect(meal).to be_persisted
    end

    it 'allows customization of meal attributes' do
      nutrition_plan = create(:nutrition_plan)
      meal_time = Time.zone.parse('2025-01-01 12:30')
      meal = create(:meal, nutrition_plan: nutrition_plan, meal_type: 'almoco', meal_time: meal_time)
      expect(meal.nutrition_plan).to eq(nutrition_plan)
      expect(meal.meal_type).to eq('almoco')
      expect(meal.meal_time.strftime('%H:%M')).to eq('12:30')
    end
  end
end
