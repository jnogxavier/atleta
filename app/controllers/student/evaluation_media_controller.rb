module Student
  class EvaluationMediaController < ApplicationController
    include Authentication
    include StudentOnlyAuthorization


    def new
      @evaluation_medium = EvaluationMedium.new
    end

    def create
      # Handle multiple file uploads from the new array structure
      media_params = evaluation_media_params
      saved_count = 0

      if media_params.present?
        media_params.each do |index, media_data|
          # Skip if file is missing
          next unless media_data[:file].present?
          @evaluation_medium = Current.user.evaluation_media.build(
            file: media_data[:file],
            media_type: media_data[:media_type] || "photo",
            category: media_data[:category],
            description: media_data[:description],
            evaluated: false,
            uploaded_at: Time.current
          )

          if @evaluation_medium.save
            saved_count += 1
          else
            # Log validation errors for debugging
            Rails.logger.warn("EvaluationMedium save failed: #{@evaluation_medium.errors.full_messages}")
          end
        end

        # Notify admins about new photos
        if saved_count > 0
          notify_admins_of_new_photos(saved_count)
          redirect_to student_dashboard_path(tab: "evaluation"),
            notice: "#{saved_count} foto(s) enviada(s) com sucesso!"
        else
          flash.now[:alert] = "Nenhuma foto foi selecionada. Por favor, selecione pelo menos uma foto."
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "Nenhuma foto foi selecionada. Por favor, selecione pelo menos uma foto."
        render :new, status: :unprocessable_entity
      end
    end

    private

    def evaluation_medium_params
      params.require(:evaluation_medium).permit(:file, :category, :description)
    end

    def evaluation_media_params
      # Permit nested evaluation_media array with file uploads
      params.permit(evaluation_media: [ :file, :media_type, :category, :description ])[:evaluation_media]
    end

    def notify_admins_of_new_photos(count)
      admins = User.where(role: "admin")
      student_name = Current.user.student_profile&.name || Current.user.name

      admins.each do |admin|
        Notification.create!(
          user: admin,
          title: "Novas fotos de avaliação",
          message: "#{student_name} enviou #{count} nova(s) foto(s) de avaliação",
          notification_type: "info",
          action_url: "/admin/evaluation_media",
          metadata: { student_id: Current.user.id, photo_count: count }
        )
      end
    end
  end
end
