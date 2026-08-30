module Admin
  class NutritionPlansController < ApplicationController
    include AdminAuthorization
    include ErrorHandler
    before_action :load_foods, only: [ :new, :create, :edit, :update, :meal_field ]

    def index
      if params[:student_id].present?
        @student = StudentProfile.find(params[:student_id])
        @nutrition_plans = @student.nutrition_plans.order(created_at: :desc)

        respond_to do |format|
          format.json do
            render json: NutritionPlanSerializer.render_collection(@nutrition_plans, view: :list)
          end
          format.html do
            @students = StudentProfile.includes(:user, :nutrition_plans).order(:name)
            @nutrition_plans = NutritionPlan.includes(:student_profile).order(created_at: :desc)
            render :index
          end
        end
      else
        @students = StudentProfile.includes(:user, :nutrition_plans).order(:name)
        @nutrition_plans = NutritionPlan.includes(:student_profile, :meals).order(created_at: :desc).page(params[:page]).per(8)
      end
    end

    def show
      @nutrition_plan = NutritionPlan.includes(
        :student_profile,
        meals: { meal_foods: :food }
      ).find(params[:id])

      respond_to do |format|
        format.json do
          render json: NutritionPlanSerializer.render(@nutrition_plan, view: :detailed)
        end
        format.html
      end
    end

    def new
      @nutrition_plan = NutritionPlan.new
      if params[:student_profile_id].present?
        @nutrition_plan.student_profile_id = params[:student_profile_id]
      end
    end

    def create
      @nutrition_plan = NutritionPlan.new(nutrition_plan_params)

      begin
        if @nutrition_plan.save
          respond_to do |format|
            format.turbo_stream { redirect_to admin_dashboard_path(tab: "nutrition"), notice: I18n.t("flash.notices.nutrition_plan_created") }
            format.html { redirect_to admin_dashboard_path(tab: "nutrition"), notice: I18n.t("flash.notices.nutrition_plan_created") }
            format.json { render json: NutritionPlanSerializer.render(@nutrition_plan, view: :detailed), status: :created }
          end
        else
          Rails.logger.error "NutritionPlan validation errors: #{@nutrition_plan.errors.full_messages.inspect}"
          @students = StudentProfile.includes(:user).order(:name)
          @foods = []
          respond_to do |format|
            format.turbo_stream { render :new, status: :unprocessable_entity }
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @nutrition_plan.errors.messages, status: :unprocessable_entity }
          end
        end
      rescue => e
        Rails.logger.error "NutritionPlan save exception: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n")
        raise
      end
    end

    def edit
      @nutrition_plan = NutritionPlan.find(params[:id])
      @students = StudentProfile.includes(:user).order(:name)
    end

    def update
      @nutrition_plan = NutritionPlan.find(params[:id])

      if @nutrition_plan.update(nutrition_plan_params)
        respond_to do |format|
          format.turbo_stream { redirect_to admin_dashboard_path(tab: "nutrition"), notice: I18n.t("flash.notices.nutrition_plan_updated") }
          format.html { redirect_to admin_dashboard_path(tab: "nutrition"), notice: I18n.t("flash.notices.nutrition_plan_updated") }
          format.json { render json: NutritionPlanSerializer.render(@nutrition_plan, view: :detailed) }
        end
      else
        @students = StudentProfile.includes(:user).order(:name)
        @foods = []
        respond_to do |format|
          format.turbo_stream { render :edit, status: :unprocessable_entity }
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @nutrition_plan.errors.messages, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @nutrition_plan = NutritionPlan.find(params[:id])
      @nutrition_plan.destroy

      respond_to do |format|
        format.html { redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.nutrition_plan_deleted") }
        format.json { head :no_content }
      end
    end

    def toggle_active
      @nutrition_plan = NutritionPlan.find(params[:id])
      @nutrition_plan.update(active: !@nutrition_plan.active)

      status = @nutrition_plan.active ? "ativado" : "desativado"
      respond_to do |format|
        format.json { render json: { active: @nutrition_plan.active } }
        format.html { redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.nutrition_plan_toggled", status: status) }
      end
    end

    def meal_field
      meal_index = params[:meal_index].to_i
      @meal = Meal.new
      @meal_index = meal_index

      html = render_to_string(
        partial: "admin/nutrition_plans/meal_field_template"
      )

      render json: { html: html }
    end

    def search
      search_query = params[:search].to_s.strip
      per_page = 8

      nutrition_plans = NutritionPlan.includes(:student_profile).order(created_at: :desc)

      if search_query.present?
        # Search by plan name or student name using unaccent for accent-insensitive matching
        normalized_query = "%#{normalize_search(search_query)}%"
        nutrition_plans = nutrition_plans.joins(:student_profile).where(
          "unaccent(LOWER(nutrition_plans.name)) ILIKE unaccent(?) OR unaccent(LOWER(student_profiles.name)) ILIKE unaccent(?)",
          normalized_query,
          normalized_query
        )
      end

      @nutrition_plans = nutrition_plans.page(params[:page]).per(per_page)

      render json: {
        html: render_to_string(partial: "admin/dashboard/nutrition_plans_items", formats: [ :html ], locals: { nutrition_plans: @nutrition_plans }),
        pagination_html: render_to_string(partial: "admin/dashboard/nutrition_pagination", formats: [ :html ], locals: { nutrition_plans: @nutrition_plans, search_query: search_query }),
        total_count: @nutrition_plans.total_count
      }
    end

    private

    def nutrition_plan_params
      params.require(:nutrition_plan).permit(
        :student_profile_id,
        :name,
        :description,
        :active,
        meals_attributes: [
          :id,
          :meal_type,
          :meal_time,
          :observations,
          :_destroy,
          meal_foods_attributes: [
            :id,
            :food_id,
            :quantity_grams,
            :_destroy
          ]
        ]
      )
    end

    def load_foods
      # Include existing meal foods for edit mode to display selected foods
      # Dynamic search still works for adding new foods
      if action_name == "edit" && params[:id]
        @nutrition_plan = NutritionPlan.find(params[:id])
        # Get all foods from existing meal_foods
        @foods = Food.where(id: @nutrition_plan.meals.joins(:meal_foods).select(:food_id).distinct).to_a
      else
        @foods = []
      end
    end
  end
end
