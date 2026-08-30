module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: I18n.t("flash.alerts.access_restricted_admin")
    end
  end
end
