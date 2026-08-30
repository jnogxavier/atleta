module Student
  class DashboardController < ApplicationController
    include StudentAuthorization

    def index
      if current_user.admin? && params[:as].present?
        # Validate that the requested user exists and is a student
        @current_user = User.includes(:student_profile, :anamnese, :evaluation_media).find_by(id: params[:as], role: :student)
        unless @current_user
          redirect_to student_dashboard_path, alert: I18n.t("flash.alerts.user_not_found")
          return
        end
      else
        @current_user = User.includes(:student_profile, :anamnese, :evaluation_media).find(current_user.id)
      end

      @profile = @current_user.student_profile
      @anamnese = @current_user.anamnese
      @evaluation_media = @current_user.evaluation_media.order(created_at: :desc)
      @notifications = current_user.notifications.unread.recent

      if @profile
        @trainings = @profile.active_trainings.includes(
          :training_strength_exercises,
          :training_mobility_exercises,
          :training_core_exercises,
          :training_cardio_exercises
        )
        @nutrition_plans = @profile.active_nutrition_plans.includes(meals: :foods).order(updated_at: :desc).page(params[:nutrition_page]).per(8)
      else
        @trainings = []
        @nutrition_plans = []
      end
    end
  end
end
