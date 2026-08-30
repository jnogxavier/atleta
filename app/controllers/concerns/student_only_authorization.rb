# Restricts a controller to students alone.
#
# Deliberately stricter than StudentAuthorization, which also admits admins so
# they can view student data. These are the self-service screens — editing your
# own profile, changing your own password, uploading your own evaluation media —
# and an admin has no business acting through them on a student's behalf.
module StudentOnlyAuthorization
  extend ActiveSupport::Concern

  included do
    # Authentication is re-declared here so it is unambiguously ordered ahead of
    # the role check: Rails keys before_action callbacks by filter name, so a
    # controller re-declaring :require_authentication would otherwise relocate it
    # after this concern's callback and answer "not a student" to a visitor who
    # is merely signed out.
    before_action :require_authentication
    before_action :require_student_only
  end

  private

  def require_student_only
    return if current_user&.student?

    redirect_to root_path, alert: I18n.t("flash.alerts.access_denied")
  end
end
