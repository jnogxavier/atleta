module Admin
  class StrengthExercisesController < ApplicationController
    include AdminAuthorization
    include ExerciseCrud

    private

    def exercise_model
      StrengthExercise
    end

    def exercise_params
      params.require(:strength_exercise).permit(:name, :muscle_group, :equipment, :description)
    end

    def exercise_json_attributes
      {
        id: @exercise.id,
        name: @exercise.name,
        muscle_group: @exercise.muscle_group,
        equipment: @exercise.equipment,
        description: @exercise.description
      }
    end
  end
end
