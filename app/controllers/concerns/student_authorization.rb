module StudentAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_student_or_admin
  end

  private

  def require_student_or_admin
    unless current_user&.student? || current_user&.admin?
      redirect_to root_path, alert: I18n.t("flash.alerts.access_restricted_students")
    end
  end
end
