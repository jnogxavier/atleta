class StrengthExercisesController < ApplicationController
  def index
    @exercises = StrengthExercise.all.order(:name).page(params[:page]).per(10)

    respond_to do |format|
      format.json do
        render json: {
          exercises: @exercises.map { |e|
            {
              id: e.id,
              name: e.name,
              muscle_group: e.muscle_group,
              equipment: e.equipment,
              description: e.description
            }
          },
          pagination: {
            current_page: @exercises.current_page,
            total_pages: @exercises.total_pages,
            total_count: @exercises.total_count,
            per_page: 10
          }
        }
      end
    end
  end
end
