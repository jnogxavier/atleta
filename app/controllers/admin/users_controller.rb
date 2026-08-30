module Admin
  class UsersController < ApplicationController
    include AdminAuthorization

    before_action :set_user, only: [ :show, :edit, :update, :destroy, :deactivate, :activate ]

    def show
    end

    def new
      @user = User.new
      @user.build_student_profile
      @user.build_partner_profile
    end

    def create
      @user = User.new(user_params)

      if @user.save
        create_profile_for_user(@user)
        redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.user_created")
      else
        @user.build_student_profile unless @user.student_profile
        @user.build_partner_profile unless @user.partner_profile
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      user_update_params = user_params.reject { |k, v| k == "password" && v.blank? }

      if @user.update(user_update_params)
        update_profile_for_user(@user)
        redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.user_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.user_deleted")
    end

    def deactivate
      if @user.id == current_user.id
        redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.self_deactivation_error")
        return
      end

      reason = params[:reason].presence || "Sem motivo especificado"

      @user.update(
        deactivation_reason: reason,
        deactivated_at: Time.current,
        deactivated_by_id: current_user.id
      )

      # Log admin action for audit trail
      log_admin_action(
        :deactivate_user,
        target_user: @user,
        notes: "Deactivated user. Reason: #{reason}"
      )

      redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.user_deactivated")
    end

    def activate
      reason = params[:reason].presence || "Sem motivo especificado"

      @user.update(
        deactivation_reason: nil,
        deactivated_at: nil,
        activation_reason: reason,
        activated_at: Time.current,
        activated_by_id: current_user.id
      )

      # Log admin action for audit trail
      log_admin_action(
        :activate_user,
        target_user: @user,
        notes: "Activated user. Reason: #{reason}"
      )

      redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.user_activated")
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted = params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :terms_accepted)

      if params[:user][:role].present? && (!@user || @user.id != current_user.id)
        permitted[:role] = params[:user][:role]
      end

      permitted
    end

    def student_profile_params
      params.require(:user).permit(student_profile_attributes: [ :name, :plan, :expires_at, :status, :value ])[:student_profile_attributes] || {}
    end

    def partner_profile_params
      params.require(:user).permit(partner_profile_attributes: [ :name, :profession, :specialty, :status ])[:partner_profile_attributes] || {}
    end

    def create_profile_for_user(user)
      case user.role
      when "student"
        user.create_student_profile!(student_profile_params) unless student_profile_params.empty?
      when "partner"
        user.create_partner_profile!(partner_profile_params) unless partner_profile_params.empty?
      end
    end

    def update_profile_for_user(user)
      case user.role
      when "student"
        if user.student_profile
          user.student_profile.update(student_profile_params) unless student_profile_params.empty?
        else
          user.create_student_profile!(student_profile_params) unless student_profile_params.empty?
        end
      when "partner"
        if user.partner_profile
          user.partner_profile.update(partner_profile_params) unless partner_profile_params.empty?
        else
          user.create_partner_profile!(partner_profile_params) unless partner_profile_params.empty?
        end
      end
    end
  end
end
