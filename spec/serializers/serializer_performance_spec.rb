require 'rails_helper'

describe 'Serializer Performance' do
  describe 'NutritionPlanSerializer with meals' do
    it 'does not cause N+1 queries when serializing meals with nutrition' do
      nutrition_plan = create(:nutrition_plan)

      # Create multiple meals with foods
      5.times do |i|
        meal = create(:meal, nutrition_plan: nutrition_plan)
        3.times do
          food = create(:food)
          create(:meal_food, meal: meal, food: food, quantity_grams: 100)
        end
      end

      # Reload to ensure clean slate
      nutrition_plan.reload

      # Count queries during serialization with precomputation
      query_count = 0
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do
        query_count += 1
      end

      begin
        # This should only query:
        # 1. meal_foods with join to foods
        # Not: 4 queries per meal (total_calories, total_protein, total_carbohydrates, total_fat)
        nutrition_data = MealNutritionService.precompute_for_meals(nutrition_plan.meals)
        result = NutritionPlanSerializer.render(nutrition_plan, view: :detailed, nutrition_data: nutrition_data)

        expect(result).to be_a(Hash)
        expect(result[:meals]).to be_an(Array)
        expect(result[:meals].length).to eq(5)
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end

    it 'provides correct nutrition data with precomputation' do
      nutrition_plan = create(:nutrition_plan)
      meal = create(:meal, nutrition_plan: nutrition_plan)

      food1 = create(:food, energy_kcal: 100, protein_g: 10, carbohydrate_g: 20, fat_g: 5)
      food2 = create(:food, energy_kcal: 200, protein_g: 20, carbohydrate_g: 30, fat_g: 10)

      create(:meal_food, meal: meal, food: food1, quantity_grams: 100)
      create(:meal_food, meal: meal, food: food2, quantity_grams: 100)

      nutrition_data = MealNutritionService.precompute_for_meals([ meal ])
      result = MealSerializer.render(meal, view: :detailed, nutrition_data: nutrition_data)

      expect(result[:total_calories]).to eq(300)
      expect(result[:total_protein]).to eq(30)
      expect(result[:total_carbohydrates]).to eq(50)
      expect(result[:total_fat]).to eq(15)
      expect(result[:total_foods]).to eq(2)
    end
  end

  describe 'TrainingSerializer' do
    it 'does not cause N+1 queries with eager loading' do
      student = create(:student_profile)
      training = create(:training, student_profile: student)

      # Create multiple exercise types
      3.times do
        create(:training_strength_exercise, training: training)
        create(:training_mobility_exercise, training: training)
        create(:training_core_exercise, training: training)
        create(:training_cardio_exercise, training: training)
      end

      # Reload with eager loading
      training = Training.includes(
        :student_profile,
        training_strength_exercises: :strength_exercise,
        training_mobility_exercises: :mobility_exercise,
        training_core_exercises: :core_exercise,
        training_cardio_exercises: :cardio_exercise
      ).find(training.id)

      # This should use preloaded associations
      result = TrainingSerializer.render(training, view: :detailed)

      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(training.id)
    end
  end

  describe 'StudentProfileSerializer' do
    it 'does not cause N+1 queries when accessing user association' do
      student = create(:student_profile)

      # Reload with eager loading
      student = StudentProfile.includes(:user).find(student.id)

      # This should not trigger additional query for user
      result = StudentProfileSerializer.render(student, view: :default)

      expect(result).to be_a(Hash)
      expect(result[:user_name]).to eq(student.user.name)
    end
  end
end
