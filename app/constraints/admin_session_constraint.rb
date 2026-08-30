# Matches a route only for a signed-in admin, reusing the application's session
# cookie. Used to gate the mounted Mission Control Jobs dashboard so it is
# reachable by admins (via their normal login) without a separate credential.
class AdminSessionConstraint
  def self.matches?(request)
    session_id = request.cookie_jar.signed[:session_id]
    return false if session_id.blank?

    session = Session.active.find_by(id: session_id)
    session.present? && session.user&.admin?
  end
end
