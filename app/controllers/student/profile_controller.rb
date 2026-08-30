module Student
  class ProfileController < ApplicationController
    include StudentOnlyAuthorization

    before_action :set_profile_and_anamnese

    def edit
    end

    def update
      if update_profile_and_anamnese
        redirect_to student_dashboard_path, notice: I18n.t("flash.notices.profile_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_profile_and_anamnese
      @user = Current.user
      @profile = @user.student_profile
      @anamnese = @user.anamnese || @user.build_anamnese
    end

    def update_profile_and_anamnese
      processed_params = user_params

      if processed_params && processed_params[:anamnese_attributes]
        anamnese_attrs = processed_params[:anamnese_attributes]

        if anamnese_attrs[:eating_motivation].is_a?(Array)
          motivations = anamnese_attrs[:eating_motivation].reject(&:blank?)
          if anamnese_attrs[:eating_motivation_other].present?
            motivations << anamnese_attrs[:eating_motivation_other]
          end
          anamnese_attrs[:eating_motivation] = motivations.join("|||")
          anamnese_attrs.delete(:eating_motivation_other)
        end
      end

      # Handle audio file separately
      audio_file = processed_params&.delete(:audio_file)

      @user.assign_attributes(processed_params) if processed_params.present?

      if @user.valid?
        # Handle audio file upload
        if audio_file.present?
          audio_recording = @user.audio_recording || @user.build_audio_recording
          audio_recording.file.attach(audio_file)
          audio_recording.save!
        end

        @user.save!
        true
      else
        false
      end
    rescue ActiveRecord::RecordInvalid, ActiveModel::UnknownAttributeError => e
      false
    end

    def user_params
      return nil unless params[:user]

      params.require(:user).permit(
        :name,
        :audio_file,
        anamnese_attributes: [
          :id,  # Required for updating existing anamnese
          :age, :height, :weight, :goal, :physical_activity_level,
          :health_conditions, :medications, :injuries, :dietary_restrictions,
          :sleep_hours, :stress_level, :smoking, :alcohol_consumption, :gender,
          :phone, :birth_date, :marital_status, :profession, :personality, :cpf, :address,
          :expectations, :training_availability, :training_location, :available_equipment,
          :digestion, :chewing, :heartburn, :gastritis, :reflux, :bowel_movement_scale, :urine_scale,
          :breakfast, :breakfast_time, :lunch, :lunch_time,
          :afternoon_snack, :afternoon_snack_time, :dinner, :dinner_time,
          :snacks_between_meals, :time_of_biggest_appetite, :satisfied_with_meals,
          :wake_up_time, :sleep_time,
          :routine_description,
          :eating_motivation_other,
          eating_motivation: []
        ]
      )
    end
  end
end
