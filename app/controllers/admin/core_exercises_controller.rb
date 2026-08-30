module Admin
  class CoreExercisesController < ApplicationController
    include AdminAuthorization
    include ExerciseCrud

    private

    def exercise_model
      CoreExercise
    end

    def exercise_params
      params.require(:core_exercise).permit(:name, :description)
    end

    def exercise_json_attributes
      {
        id: @exercise.id,
        name: @exercise.name,
        description: @exercise.description
      }
    end
  end
end
