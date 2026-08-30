module Admin
  class EvaluationMediaController < ApplicationController
    include AdminAuthorization

    def index
      type_filter = params[:type]
      student_id = params[:student_id]

      # Build evaluation media query with all necessary includes to avoid N+1
      media_data = []

      if type_filter.blank? || type_filter != "audio"
        @media = EvaluationMedium.includes(user: [ :student_profile ])
                                 .order(uploaded_at: :desc, created_at: :desc)

        @media = @media.where(user_id: student_id) if student_id.present?

        if params[:status].present?
          case params[:status]
          when "pending"
            @media = @media.pending_evaluation
          when "evaluated"
            @media = @media.evaluated
          end
        end

        @media = @media.where(media_type: type_filter) if type_filter.present?

        # Format all media without N+1 queries
        media_data.concat(@media.map { |m| format_medium(m) })
      end

      # Fetch audio recordings with all necessary includes
      if type_filter.blank? || type_filter == "audio"
        audio_query = AudioRecording.includes(user: [ :student_profile, :anamnese ])
                                    .joins(:user)
                                    .where(users: { registration_status: :complete })
                                    .order(created_at: :desc)
        audio_query = audio_query.where(user_id: student_id) if student_id.present?

        # Format all audio without N+1 queries
        media_data.concat(audio_query.map { |a| format_audio_recording(a) })
      end

      # Sort combined results by date (both lists are already sorted in DB)
      sorted_media = media_data.sort_by { |m| m[:uploaded_at] }.reverse

      respond_to do |format|
        format.json do
          render json: sorted_media
        end
      end
    end

    def show
      @medium = EvaluationMedium.includes(user: :student_profile).find(params[:id])

      respond_to do |format|
        format.json do
          render json: format_medium(@medium)
        end
      end
    end

    def update
      @medium = EvaluationMedium.find(params[:id])

      if @medium.update(medium_params)
        respond_to do |format|
          format.json { render json: { success: true, medium: @medium } }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, errors: @medium.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @medium = EvaluationMedium.find(params[:id])
      @medium.destroy

      respond_to do |format|
        format.json { render json: { success: true } }
      end
    end

    private

    def medium_params
      params.permit(:admin_notes, :evaluated)
    end

    def format_medium(m)
      student_profile = m.user.student_profile
      file_url = m.file_url.present? ? m.file_url : (m.file.attached? ? url_for(m.file) : nil)

      {
        id: m.id,
        student_name: student_profile&.name || m.user.name,
        student_id: m.user_id,
        media_type: m.media_type,
        category: m.category,
        file_url: file_url,
        description: m.description,
        uploaded_at: m.uploaded_at || m.created_at,
        evaluated: m.evaluated,
        admin_notes: m.admin_notes
      }
    end

    def format_audio_recording(a)
      student_profile = a.user.student_profile
      anamnese = a.user.anamnese

      {
        id: "audio_#{a.id}",
        student_name: student_profile&.name || a.user.name,
        student_id: a.user_id,
        media_type: "audio",
        category: "Rotina",
        file_url: a.file.attached? ? url_for(a.file) : nil,
        description: anamnese&.routine_description || "Descrição de rotina (áudio)",
        uploaded_at: a.created_at,
        evaluated: false,
        admin_notes: ""
      }
    end
  end
end
