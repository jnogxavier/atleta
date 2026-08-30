require 'rails_helper'

RSpec.describe Food, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:meal_foods).dependent(:destroy) }
    it { is_expected.to have_many(:meals).through(:meal_foods) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:energy_kcal) }
    it { is_expected.to validate_presence_of(:protein_g) }

    it { is_expected.to validate_numericality_of(:energy_kcal).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:protein_g).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:carbohydrate_g).is_greater_than_or_equal_to(0) }
  end

  describe 'scopes' do
    let!(:fruit) { create(:food, category: 'Frutas', name: 'Maçã') }
    let!(:vegetable) { create(:food, category: 'Vegetais', name: 'Brócolis') }
    let!(:protein_food) { create(:food, category: 'Proteínas', name: 'Frango') }

    describe '.by_category' do
      it 'returns foods in specified category' do
        expect(Food.by_category('Frutas')).to include(fruit)
        expect(Food.by_category('Frutas')).not_to include(vegetable)
      end

      it 'returns empty array for non-existent category' do
        expect(Food.by_category('Não Existe')).to be_empty
      end
    end
  end

  describe '.categories' do
    let!(:fruit) { create(:food, category: 'Frutas') }
    let!(:vegetable) { create(:food, category: 'Vegetais') }
    let!(:protein_food) { create(:food, category: 'Proteínas') }

    it 'returns distinct categories sorted alphabetically' do
      categories = Food.categories
      expect(categories).to include('Frutas', 'Vegetais', 'Proteínas')
      expect(categories).to eq(categories.sort)
    end

    it 'excludes nil categories' do
      create(:food, category: nil)
      expect(Food.categories).not_to include(nil)
    end
  end

  describe 'constants' do
    it 'has STANDARD_QUANTITY_GRAMS set to 100.0' do
      expect(Food::STANDARD_QUANTITY_GRAMS).to eq(100.0)
    end
  end

  describe 'factory' do
    it 'creates a valid food with factory' do
      food = create(:food)
      expect(food).to be_valid
      expect(food).to be_persisted
    end

    it 'allows customization of food attributes' do
      food = create(:food, name: 'Arroz', energy_kcal: 130, category: 'Grãos')
      expect(food.name).to eq('Arroz')
      expect(food.energy_kcal).to eq(130)
      expect(food.category).to eq('Grãos')
    end
  end
end
