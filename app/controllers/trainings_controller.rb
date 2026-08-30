class TrainingsController < ApplicationController
  include Authentication

  before_action :require_authentication
  before_action :set_student_profile
  before_action :set_training, only: [ :show ]

  def index
    @trainings = @student_profile.active_trainings
  end

  def show
    @strength_exercises = @training.training_strength_exercises.includes(:strength_exercise)
    @mobility_exercises = @training.training_mobility_exercises.includes(:mobility_exercise)
    @core_exercises = @training.training_core_exercises.includes(:core_exercise)
    @cardio_exercises = @training.training_cardio_exercises.includes(:cardio_exercise)
  end

  private

  def set_student_profile
    if current_user.admin? && params[:as].present?
      # Validate that the requested user exists and is a student
      user = User.find_by(id: params[:as], role: :student)
      unless user
        redirect_to root_path, alert: I18n.t("flash.alerts.user_not_found")
        return
      end

      @student_profile = user.student_profile

      # Log admin access to student data for audit trail
      # Admins CAN view student data, but we log it for compliance/security
      log_admin_action(
        :view_student_data,
        target_user: user,
        notes: "Viewed trainings for student #{user.email_address}"
      )
    else
      @student_profile = current_user.student_profile
    end

    unless @student_profile
      redirect_to root_path, alert: I18n.t("flash.alerts.student_profile_not_found")
    end
  end

  def set_training
    # Scoping through @student_profile already prevents reaching another
    # student's training; the policy check states the rule explicitly and keeps
    # this controller consistent with the rest.
    @training = @student_profile.trainings.find(params[:id])
    authorize @training
  end
end
