module ExerciseCrud
  extend ActiveSupport::Concern

  included do
    before_action :set_exercise, only: [ :show, :update, :destroy ]
  end

  def show
    respond_to do |format|
      format.json do
        render json: exercise_json_attributes
      end
    end
  end

  def create
    @exercise = exercise_model.new(exercise_params)

    if @exercise.save
      respond_to do |format|
        format.json { render json: { success: true, exercise: @exercise } }
        format.html { redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.exercise_created", name: @exercise.name) }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: @exercise.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.exercise_creation_error") }
      end
    end
  end

  def update
    if @exercise.update(exercise_params)
      respond_to do |format|
        format.json { render json: { success: true, exercise: @exercise } }
        format.html { redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.exercise_updated", name: @exercise.name) }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: @exercise.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.exercise_update_error") }
      end
    end
  end

  def destroy
    @exercise.destroy

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to admin_dashboard_path, notice: "Exercício excluído com sucesso!" }
    end
  end

  def search
    search_query = params[:search].to_s.strip
    exercise_type = params[:type]&.to_sym
    per_page = 10

    type_mapping = {
      strength: StrengthExercise,
      mobility: MobilityExercise,
      core: CoreExercise,
      cardio: CardioExercise
    }

    current_model = exercise_model
    current_type = type_mapping.find { |_type, model| model == current_model }&.first

    # Search all types if type=all is passed or if no specific type is provided
    if exercise_type == :all || (exercise_type.nil? && current_type.nil?)
      all_exercises = []
      html_parts = []

      type_mapping.each do |type, model|
        exercises = model.order("LOWER(name)")

        if search_query.present?
          # Use unaccent for accent-insensitive search
          normalized_query = "%#{search_query}%"
          name_match = "unaccent(LOWER(name)) ILIKE unaccent(?)"

          if model.column_names.include?("muscle_group")
            exercises = exercises.where(
              "#{name_match} OR unaccent(LOWER(muscle_group)) ILIKE unaccent(?) OR unaccent(LOWER(equipment)) ILIKE unaccent(?)",
              normalized_query,
              normalized_query,
              normalized_query
            )
          elsif model.column_names.include?("description")
            exercises = exercises.where(
              "#{name_match} OR unaccent(LOWER(description)) ILIKE unaccent(?)",
              normalized_query,
              normalized_query
            )
          else
            exercises = exercises.where(name_match, normalized_query)
          end
        end

        exercises_list = exercises.limit(100).to_a
        all_exercises.concat(exercises_list)
        if exercises_list.any?
          html_parts << render_to_string(partial: "admin/dashboard/exercise_items", formats: [ :html ], locals: { exercises: exercises_list, exercise_type: type })
        end
      end

      render json: {
        html: html_parts.join,
        total_count: all_exercises.count
      }
    else
      final_type = exercise_type || current_type || :strength
      model = type_mapping[final_type] || StrengthExercise
      exercises = model.order("LOWER(name)")

      if search_query.present?
        # Use unaccent for accent-insensitive search
        normalized_query = "%#{search_query}%"
        name_match = "unaccent(LOWER(name)) ILIKE unaccent(?)"

        if model.column_names.include?("muscle_group")
          exercises = exercises.where(
            "#{name_match} OR unaccent(LOWER(muscle_group)) ILIKE unaccent(?) OR unaccent(LOWER(equipment)) ILIKE unaccent(?)",
            normalized_query,
            normalized_query,
            normalized_query
          )
        elsif model.column_names.include?("description")
          exercises = exercises.where(
            "#{name_match} OR unaccent(LOWER(description)) ILIKE unaccent(?)",
            normalized_query,
            normalized_query
          )
        else
          exercises = exercises.where(name_match, normalized_query)
        end
      end

      exercises = exercises.to_a

      # For training modal, return just the array of exercises
      if params[:for_modal] == "true"
        render json: exercises.map { |e|
          {
            id: e.id,
            name: e.name,
            muscle_group: e.try(:muscle_group),
            equipment: e.try(:equipment),
            description: e.try(:description)
          }
        }
      elsif params[:format] == "json" || request.headers["Accept"]&.include?("application/json")
        html = render_to_string(partial: "admin/dashboard/exercise_items", formats: [ :html ], locals: { exercises: exercises, exercise_type: final_type })
        render json: {
          html: html,
          total_count: exercises.count
        }
      else
        @exercises = Kaminari.paginate_array(exercises)
          .page(params[:page])
          .per(per_page)

        html = render_to_string(partial: "admin/dashboard/exercise_items", formats: [ :html ], locals: { exercises: @exercises, exercise_type: final_type })

        pagination_html = ""
        if @exercises.total_pages > 1
          pagination_html = render_to_string(partial: "shared/exercises_pagination", formats: [ :html ], locals: {
            exercises: @exercises,
            search_query: search_query,
            exercise_type: final_type
          })
        end

        render json: {
          html: html,
          total_count: @exercises.total_count,
          pagination_html: pagination_html
        }
      end
    end
  end

  private

  def set_exercise
    @exercise = exercise_model.find(params[:id])
  end

  def exercise_model
    raise NotImplementedError, "#{self.class} must implement #exercise_model"
  end

  def exercise_params
    raise NotImplementedError, "#{self.class} must implement #exercise_params"
  end

  def exercise_json_attributes
    raise NotImplementedError, "#{self.class} must implement #exercise_json_attributes"
  end
end
