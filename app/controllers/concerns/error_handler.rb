# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
    rescue_from ArgumentError, with: :handle_argument_error
  end

  private

  def handle_not_found(exception)
    Rails.logger.error "RecordNotFound: #{exception.message}"

    respond_to do |format|
      format.json { render json: { error: "Resource not found" }, status: :not_found }
      format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.resource_not_found", default: "Resource not found") }
    end
  end

  def handle_invalid_record(exception)
    Rails.logger.error "RecordInvalid: #{exception.record.errors.full_messages.inspect}"

    respond_to do |format|
      format.json { render json: { errors: exception.record.errors.messages }, status: :unprocessable_entity }
      format.html do
        flash.now[:alert] = exception.record.errors.full_messages.join(", ")
        render action_name, status: :unprocessable_entity
      end
    end
  end

  def handle_argument_error(exception)
    Rails.logger.error "ArgumentError: #{exception.message}"

    respond_to do |format|
      format.json { render json: { error: exception.message }, status: :bad_request }
      format.html do
        flash[:alert] = exception.message
        redirect_back fallback_location: admin_dashboard_path
      end
    end
  end
end
