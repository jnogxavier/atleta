class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  include RoleRedirectable
  allow_browser versions: :modern

  stale_when_importmap_changes

  # Order matters: the generic handler is declared first so the more specific
  # handlers below take precedence (rescue_from matches most-recently-declared first).
  rescue_from StandardError, with: :handle_unexpected_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

  protected

  # Pundit resolves policies against the signed-in user.
  def pundit_user
    current_user
  end

  def handle_not_authorized(_exception)
    if request.format.json?
      render json: { success: false, errors: [ I18n.t("flash.alerts.access_denied") ] }, status: :forbidden
    else
      # Send signed-in users back to their own dashboard rather than to the
      # login redirect at root, which would only bounce them there anyway.
      fallback = current_user ? dashboard_path_for(current_user) : root_path
      redirect_to fallback, alert: I18n.t("flash.alerts.access_denied")
    end
  end

  def handle_not_found(_exception)
    render_error_response(:not_found, "public/404.html", "Recurso não encontrado.")
  end

  def handle_bad_request(_exception)
    render_error_response(:bad_request, "public/400.html", "Requisição inválida.")
  end

  def handle_unexpected_error(exception)
    Rails.logger.error("#{exception.class}: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))
    report_error(exception)

    # Never swallow unexpected errors outside production — surface them so they
    # get diagnosed instead of silently returning a 500 during development/CI.
    raise exception unless Rails.env.production?

    render_error_response(
      :internal_server_error,
      "public/500.html",
      "Um erro inesperado ocorreu. Por favor, tente novamente."
    )
  end

  private

  # Send unexpected errors to the error tracker when one is configured.
  def report_error(exception)
    Sentry.capture_exception(exception) if defined?(Sentry) && Sentry.initialized?
  end

  def render_error_response(status, page, json_message)
    if request.format.json?
      render json: { success: false, errors: [ json_message ] }, status: status
    else
      render file: Rails.root.join(page), status: status, layout: false
    end
  end

  protected

  def normalize_search(query)
    query
      .to_s
      .strip
      .downcase
      .unicode_normalize(:nfd)
      .gsub(/\p{Mn}/, "")
  end

  def normalized_match?(value, search_pattern)
    normalized_value = normalize_search(value.to_s)
    normalized_pattern = normalize_search(search_pattern.to_s)
    normalized_value.include?(normalized_pattern)
  end

  # Standardized error response format for JSON APIs
  # Ensures consistent error response structure across all controllers
  def render_error(message_or_errors, status: :unprocessable_entity)
    errors = if message_or_errors.is_a?(Array)
               message_or_errors
    elsif message_or_errors.is_a?(Hash)
               # Handle ActiveRecord errors hash
               message_or_errors.map { |key, msgs| "#{key}: #{msgs.join(', ')}" }
    else
               [ message_or_errors.to_s ]
    end

    render json: { success: false, errors: errors }, status: status
  end

  # Log admin actions for audit trail
  # Only logs if current_user is admin, doesn't prevent access
  def log_admin_action(action, target_user: nil, target_type: nil, notes: nil)
    return unless current_user&.admin?

    AdminAuditLog.create!(
      admin_id: current_user.id,
      target_user_id: target_user&.id,
      action: action,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      target_type: target_type,
      notes: notes
    )
  rescue => e
    # Don't fail the request if logging fails
    Rails.logger.error("Failed to log admin action: #{e.message}")
  end
end
