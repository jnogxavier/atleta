class SessionsController < ApplicationController
  include RoleRedirectable

  allow_unauthenticated_access only: %i[ new create ]

  # Throttle login attempts per IP to blunt credential-stuffing / brute force.
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: I18n.t("flash.alerts.rate_limited") }

  before_action :resume_session, only: :new
  before_action :redirect_authenticated_users, only: :new

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.deactivated_at.present?
        redirect_to new_session_path, alert: I18n.t("flash.alerts.account_deactivated"), status: :see_other
        return
      end

      start_new_session_for user
      redirect_to dashboard_path_for(user), notice: I18n.t("flash.notices.login_success"), status: :see_other
    else
      redirect_to new_session_path, alert: I18n.t("flash.alerts.invalid_credentials"), status: :see_other
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: I18n.t("flash.notices.logout_success"), status: :see_other
  end

  private

  def redirect_authenticated_users
    return unless current_user
    redirect_to dashboard_path_for(current_user)
  end
end
