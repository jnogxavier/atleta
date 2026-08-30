class PasswordsController < ApplicationController
  allow_unauthenticated_access

  # Throttle reset requests per IP to limit account enumeration / mail flooding.
  rate_limit to: 5, within: 5.minutes, only: :create,
             with: -> { redirect_to new_password_path, alert: I18n.t("flash.alerts.rate_limited") }

  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    # Check password expiration before updating
    if @user.password_expired?
      redirect_to new_password_path, alert: I18n.t("flash.alerts.password_reset_expired")
      return
    end

    if @user.update(params.permit(:password, :password_confirmation))
      # Clear password expiration directly without triggering validations
      # This is safe because we're only updating internal state after successful password update
      @user.update_column(:password_expires_at, nil)
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: I18n.t("flash.notices.password_reset_success")
    else
      redirect_to edit_password_path(params[:token]), alert: I18n.t("flash.errors.password_mismatch")
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: I18n.t("flash.alerts.password_reset_invalid")
    end
end
