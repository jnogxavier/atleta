module Admin
  class CardioExercisesController < ApplicationController
    include AdminAuthorization
    include ExerciseCrud

    private

    def exercise_model
      CardioExercise
    end

    def exercise_params
      params.require(:cardio_exercise).permit(:name, :cardio_type, :description)
    end

    def exercise_json_attributes
      {
        id: @exercise.id,
        name: @exercise.name,
        cardio_type: @exercise.cardio_type,
        description: @exercise.description
      }
    end
  end
end
