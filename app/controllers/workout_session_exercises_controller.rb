class WorkoutSessionExercisesController < ApplicationController
  include Authentication

  before_action :require_authentication
  before_action :set_and_authorize_workout_session_exercise

  # Fails the request if an action forgets to call `authorize`.
  after_action :verify_authorized

  def toggle
    @workout_session_exercise.toggle_completion!

    redirect_back fallback_location: student_dashboard_path
  end

  private

  def set_and_authorize_workout_session_exercise
    # Eager load associations to prevent N+1 queries during authorization
    @workout_session_exercise = WorkoutSessionExercise
      .includes(workout_session: { student_profile: :user })
      .find(params[:id])

    authorize @workout_session_exercise, :toggle?
  end
end
