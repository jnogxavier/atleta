module Admin
  class PendingRegistrationsController < ApplicationController
    include AdminAuthorization

    def index
      redirect_to admin_dashboard_path
    end

    def approve
      @registration = PendingRegistration.find(params[:id])

      ActiveRecord::Base.transaction do
        @registration.approve!(current_user)
        user = User.find_by(email_address: @registration.email)

        if user && user.student_profile
          user.student_profile.update!(status: :active)
          flash[:notice] = I18n.t("flash.notices.registration_approved_simple", name: @registration.name)
        elsif user
          user.create_student_profile!(
            name: @registration.name,
            status: :active,
            plan: nil
          )
          flash[:notice] = I18n.t("flash.notices.registration_approved_created", name: @registration.name)
        else
          temporary_password = SecureRandom.alphanumeric(16)

          user = User.create!(
            email_address: @registration.email,
            password: temporary_password,
            password_confirmation: temporary_password,
            role: "student",
            registration_status: :complete,
            terms_accepted: true
          )

          user.create_student_profile!(
            name: @registration.name,
            status: :active,
            plan: nil
          )

          # Send temporary password via secure email instead of displaying in UI
          UserMailer.temporary_password(user, temporary_password).deliver_later

          flash[:notice] = I18n.t("flash.notices.registration_approved_emailed", name: @registration.name, email: @registration.email)
        end

        redirect_to admin_dashboard_path
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      Rails.logger.error("Registration approval failed: #{e.message}")
      redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.registration_approval_error")
    end

    def reject
      @registration = PendingRegistration.find(params[:id])
      rejection_reason = params[:rejection_reason]

      if @registration.reject!(current_user, rejection_reason)
        user = User.find_by(email_address: @registration.email)

        if user && user.student_profile
          user.student_profile.update!(
            rejected: true,
            rejected_at: Time.current,
            rejection_reason: rejection_reason
          )

          user.notifications.create!(
            title: "Cadastro Rejeitado",
            message: rejection_reason.present? ?
              "Seu cadastro foi rejeitado. Motivo: #{rejection_reason}" :
              "Seu cadastro foi rejeitado. Entre em contato para mais informações.",
            notification_type: "alert"
          )
        end

        redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.registration_rejected")
      else
        redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.registration_rejection_error")
      end
    end

    def reset
      @registration = PendingRegistration.find(params[:id])

      if @registration.reset_to_pending!
        redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.registration_reset")
      else
        redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.registration_reset_error")
      end
    end

    def destroy
      @registration = PendingRegistration.find(params[:id])
      @registration.destroy
      redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.registration_deleted")
    end

    def details
      @registration = PendingRegistration.find(params[:id])
      @user = User.find_by(email_address: @registration.email)
    end
  end
end
