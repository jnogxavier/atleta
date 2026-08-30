# Error tracking / performance monitoring.
#
# This stays completely inert until SENTRY_DSN is provided, so it is safe to
# ship without an account configured. To enable in production, set SENTRY_DSN
# (and optionally SENTRY_TRACES_SAMPLE_RATE, default 0.1).
#
# send_default_pii is deliberately left OFF: this application stores health
# data (anamnese, medications, CPF), and we must not ship request bodies,
# cookies, or user identifiers to a third party by default.
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [ :active_support_logger ]
    config.send_default_pii = false
    config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f
    config.enabled_environments = %w[ production ]
  end
end
