module PartnerAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_partner
  end

  private

  def require_partner
    unless current_user&.partner?
      redirect_to root_path, alert: I18n.t("flash.alerts.access_restricted_partners")
    end
  end
end
