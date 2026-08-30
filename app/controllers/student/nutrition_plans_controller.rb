require_relative "../../presenters/nutrition_plan_pdf_presenter"

module Student
  class NutritionPlansController < ApplicationController
    include StudentAuthorization

    # Fails the request if an action forgets to call `authorize`.
    after_action :verify_authorized
    before_action :set_nutrition_plan, only: [ :show ]

    def show
      # Precompute nutrition data to prevent N+1 queries in presenter
      nutrition_data = MealNutritionService.precompute_for_meals(@nutrition_plan.meals)
      @presenter = NutritionPlanPdfPresenter.new(@nutrition_plan, @nutrition_plan.student_profile, nutrition_data)
    end

    private

    def set_nutrition_plan
      @nutrition_plan = NutritionPlan.includes(
        student_profile: :user,
        meals: { meal_foods: :food }
      ).find(params[:id])
      authorize @nutrition_plan
    end
  end
end
