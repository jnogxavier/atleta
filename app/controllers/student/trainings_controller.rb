require_relative "../../presenters/training_pdf_presenter"

module Student
  class TrainingsController < ApplicationController
    include StudentAuthorization

    # Fails the request if an action forgets to call `authorize`.
    after_action :verify_authorized

    before_action :set_training, only: [ :show ]

    def show
      @presenter = TrainingPdfPresenter.new(@training, @training.student_profile)
    end

    private

    def set_training
      @training = Training.includes(
        student_profile: :user,
        training_strength_exercises: :strength_exercise,
        training_mobility_exercises: :mobility_exercise,
        training_core_exercises: :core_exercise,
        training_cardio_exercises: :cardio_exercise
      ).find(params[:id])
      authorize @training
    end
  end
end
