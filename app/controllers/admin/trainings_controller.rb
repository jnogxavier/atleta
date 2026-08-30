module Admin
  class TrainingsController < ApplicationController
    include AdminAuthorization
    include ErrorHandler

    def index
      if params[:fetch_students].present?
        students = StudentQueryService.fetch_students(
          search_query: params[:q],
          include_inactive: params[:include_inactive] == "true"
        )
        render json: students
        return
      end

      if params[:student_id].present?
        @student = StudentProfile.find(params[:student_id])
        @trainings = @student.trainings
                             .includes(:student_profile)
                             .order(created_at: :desc)

        respond_to do |format|
          format.json do
            render json: TrainingSerializer.render_collection(@trainings, view: :summary)
          end
          format.html do
            @students = StudentProfile.includes(:user, :trainings).order(:name)
            @trainings = Training.includes(:student_profile).order(created_at: :desc)
            render :index
          end
        end
      else
        @students = StudentProfile.includes(:user, :trainings).order(:name)
        @trainings = Training.includes(:student_profile)
                             .order(created_at: :desc)
                             .page(params[:page])
                             .per(10)

        respond_to do |format|
          format.json do
            render json: {
              trainings: TrainingSerializer.render_collection(@trainings, view: :list),
              total_pages: @trainings.total_pages,
              current_page: @trainings.current_page,
              total_count: @trainings.total_count
            }
          end
          format.html { render :index }
        end
      end
    end

    def show
      @training = Training.includes(
        :student_profile,
        training_strength_exercises: :strength_exercise,
        training_mobility_exercises: :mobility_exercise,
        training_core_exercises: :core_exercise,
        training_cardio_exercises: :cardio_exercise
      ).find(params[:id])

      respond_to do |format|
        format.json do
          render json: TrainingSerializer.render(@training, view: :detailed)
        end
      end
    end

    def new
      @training = Training.new
      @students = StudentProfile.includes(:user).order(:name)
      # Load exercises on-demand via AJAX instead of loading all at once
      # This improves page load time significantly
      @strength_exercises = StrengthExercise.order(:name).limit(100)
      @mobility_exercises = MobilityExercise.order(:name).limit(100)
      @core_exercises = CoreExercise.order(:name).limit(100)
      @cardio_exercises = CardioExercise.order(:name).limit(100)
    end

    def create
      student_profile_id = params[:student_profile_id] || params.dig(:training, :student_profile_id)
      raise ActionController::ParameterMissing, :student_profile_id if student_profile_id.blank?

      @student = StudentProfile.find(student_profile_id)
      @training = @student.trainings.build(training_params)

      if @training.save
        if params[:exercises]
          TrainingExerciseService.new(@training).add_exercises(exercises_params)
        elsif params[:strength_exercises] || params[:mobility_exercises] || params[:core_exercises] || params[:cardio_exercises]
          TrainingExerciseService.new(@training).add_exercises(exercise_params)
        end

        respond_to do |format|
          format.json { render json: { success: true, training: TrainingSerializer.render(@training, view: :detailed) } }
          format.html { redirect_to admin_trainings_path, notice: I18n.t("flash.notices.training_created", name: @training.name) }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, error: @training.errors.full_messages.join(", ") }, status: :unprocessable_entity }
          format.html do
            @students = StudentProfile.includes(:user).order(:name)
            load_exercises
            flash.now[:alert] = @training.errors.full_messages.join(", ")
            render :new, status: :unprocessable_entity
          end
        end
      end
    end

    def edit
      @training = Training.find(params[:id])
      @students = StudentProfile.includes(:user).order(:name)
      load_exercises
    end

    def update
      @training = Training.find(params[:id])

      if @training.update(training_params)
        if params[:exercises]
          TrainingExerciseService.new(@training).update_exercises(exercises_params)
        elsif params[:strength_exercises] || params[:mobility_exercises] || params[:core_exercises] || params[:cardio_exercises]
          TrainingExerciseService.new(@training).update_exercises(exercise_params)
        end

        respond_to do |format|
          format.json { render json: { success: true, training: TrainingSerializer.render(@training, view: :detailed) } }
          format.html { redirect_to admin_trainings_path, notice: I18n.t("flash.notices.training_updated") }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, error: @training.errors.full_messages.join(", ") }, status: :unprocessable_entity }
          format.html do
            @students = StudentProfile.includes(:user).order(:name)
            load_exercises
            render :edit, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @training = Training.find(params[:id])
      @training.destroy

      respond_to do |format|
        format.json { render json: { success: true } }
        format.html { redirect_to admin_trainings_path, notice: I18n.t("flash.notices.training_deleted") }
      end
    end

    def toggle_active
      @training = Training.find(params[:id])
      @training.update(active: !@training.active)

      status = @training.active? ? "ativado" : "desativado"
      redirect_to admin_trainings_path, notice: I18n.t("flash.notices.training_status_changed", status: status)
    end

    def autocomplete
      students = StudentQueryService.fetch_students(
        search_query: params[:q],
        include_inactive: false,
        limit: 10
      )
      render json: students
    end

    def autocomplete_with_inactive
      students = StudentQueryService.fetch_students(
        search_query: params[:q],
        include_inactive: true,
        limit: 10
      )
      render json: students
    end

    def search_exercises
      exercises = ExerciseSearchService.search(params[:type], params[:query])
      render json: exercises
    end

    private

    def training_params
      if params[:training].present?
        params.require(:training).permit(:name, :day, :description, :active, :notes)
      else
        params.permit(:name, :day, :description, :active, :notes)
      end
    end

    def load_exercises
      @strength_exercises = StrengthExercise.order(:name).limit(100)
      @mobility_exercises = MobilityExercise.order(:name).limit(100)
      @core_exercises = CoreExercise.order(:name).limit(100)
      @cardio_exercises = CardioExercise.order(:name).limit(100)
    end

    def exercise_params
      {
        "strength" => permit_nested_exercises(:strength_exercises, [ :id, :sets, :reps, :rest, :order, :notes ]),
        "mobility" => permit_nested_exercises(:mobility_exercises, [ :id, :sets, :duration, :order, :notes ]),
        "core" => permit_nested_exercises(:core_exercises, [ :id, :sets, :reps, :rest, :order, :notes ]),
        "cardio" => permit_nested_exercises(:cardio_exercises, [ :id, :sets, :duration, :intensity, :order, :notes ])
      }.compact
    end

    def permit_nested_exercises(key, allowed_fields)
      return nil unless params[key]

      exercises_param = params[key]
      result = {}

      exercises_param.each do |exercise_id, fields|
        result[exercise_id] = fields.permit(*allowed_fields).to_h if fields.is_a?(ActionController::Parameters)
      end

      result.empty? ? nil : result
    end

    def exercises_params
      return {} unless params[:exercises]

      permitted = {}

      params[:exercises].permit(strength_exercises: [ :id, :sets, :reps, :rest, :order, :notes, :_destroy ], mobility_exercises: [ :id, :sets, :duration, :order, :notes, :_destroy ], core_exercises: [ :id, :sets, :reps, :rest, :order, :notes, :_destroy ], cardio_exercises: [ :id, :sets, :duration, :intensity, :order, :notes, :_destroy ]).to_h.each do |type, exercises|
        next unless [ "strength_exercises", "mobility_exercises", "core_exercises", "cardio_exercises" ].include?(type.to_s)

        simplified_type = type.sub(/_exercises$/, "")
        permitted[simplified_type] = {}
        exercises.each do |exercise_id, details|
          permitted[simplified_type][exercise_id] = details.slice("id", "sets", "reps", "rest", "duration", "intensity", "notes")
        end
      end

      permitted
    end
  end
end
