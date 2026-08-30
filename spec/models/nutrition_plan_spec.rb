require 'rails_helper'

RSpec.describe NutritionPlan, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:student_profile) }
    it { is_expected.to have_many(:meals).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:student_profile) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:meals).allow_destroy(true) }
  end

  describe 'callbacks' do
    describe 'after_initialize' do
      it 'sets active to true by default for new records' do
        nutrition_plan = NutritionPlan.new
        expect(nutrition_plan.active).to be true
      end

      it 'does not override active if already set' do
        nutrition_plan = NutritionPlan.new(active: false)
        expect(nutrition_plan.active).to be false
      end

      it 'does not set defaults for persisted records' do
        nutrition_plan = create(:nutrition_plan, active: false)
        expect(nutrition_plan.active).to be false
      end
    end
  end

  describe 'scopes' do
    let(:student_profile) { create(:student_profile) }
    let!(:active_plan) { create(:nutrition_plan, student_profile: student_profile, active: true) }
    let!(:inactive_plan) { create(:nutrition_plan, student_profile: student_profile, active: false) }

    describe '.active' do
      it 'returns only active nutrition plans' do
        expect(NutritionPlan.active).to include(active_plan)
        expect(NutritionPlan.active).not_to include(inactive_plan)
      end
    end

    describe '.recent' do
      it 'returns plans ordered by created_at descending' do
        old_plan = create(:nutrition_plan, student_profile: student_profile, created_at: 1.week.ago)
        new_plan = create(:nutrition_plan, student_profile: student_profile, created_at: 1.day.ago)

        plans = NutritionPlan.recent
        plan_ids = plans.pluck(:id)
        expect(plan_ids.index(new_plan.id)).to be < plan_ids.index(old_plan.id)
      end
    end
  end

  describe '#total_meals' do
    let(:student_profile) { create(:student_profile) }
    let(:nutrition_plan) { create(:nutrition_plan, student_profile: student_profile) }

    it 'returns the number of meals' do
      create_list(:meal, 3, nutrition_plan: nutrition_plan)
      expect(nutrition_plan.total_meals).to eq(3)
    end

    it 'returns 0 when there are no meals' do
      expect(nutrition_plan.total_meals).to eq(0)
    end
  end

  describe 'factory' do
    it 'creates a valid nutrition plan with factory' do
      nutrition_plan = create(:nutrition_plan)
      expect(nutrition_plan).to be_valid
      expect(nutrition_plan).to be_persisted
    end

    it 'allows customization of nutrition plan attributes' do
      student_profile = create(:student_profile)
      nutrition_plan = create(:nutrition_plan, name: 'Plano Fitness', student_profile: student_profile, active: true)
      expect(nutrition_plan.name).to eq('Plano Fitness')
      expect(nutrition_plan.student_profile).to eq(student_profile)
      expect(nutrition_plan.active).to be true
    end
  end

  describe 'edge cases' do
    let(:student_profile) { create(:student_profile) }

    it 'handles nutrition plans with many meals' do
      nutrition_plan = create(:nutrition_plan, student_profile: student_profile)
      create_list(:meal, 50, nutrition_plan: nutrition_plan)
      expect(nutrition_plan.total_meals).to eq(50)
    end

    it 'can be updated with new meals via nested attributes' do
      nutrition_plan = create(:nutrition_plan, student_profile: student_profile)
      nutrition_plan.update(
        meals_attributes: [
          { meal_type: 'cafe_da_manha', meal_time: '08:00' },
          { meal_type: 'almoco', meal_time: '12:30' }
        ]
      )
      expect(nutrition_plan.meals.count).to eq(2)
    end
  end
end
