class MobilityExercisesController < ApplicationController
  def index
    @exercises = MobilityExercise.all.order(:name).page(params[:page]).per(10)

    respond_to do |format|
      format.json do
        render json: {
          exercises: @exercises.map { |e|
            {
              id: e.id,
              name: e.name,
              region: e.region,
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
