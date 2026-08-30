# The Mission Control Jobs dashboard is gated by AdminSessionConstraint on its
# mount (admins only, via the app's own session). Disable the gem's separate
# HTTP Basic auth, which otherwise fails closed with a 401 because no basic-auth
# credentials are configured — that is what made the dashboard unreachable.
Rails.application.config.after_initialize do
  MissionControl::Jobs.http_basic_auth_enabled = false
end
