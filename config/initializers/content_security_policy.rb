# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    # Views still carry inline <style> blocks and style="" attributes, and a
    # nonce cannot cover a style attribute. Scripts are the injection vector
    # this policy exists for, so inline styles are allowed and inline scripts
    # are not -- they have to carry the nonce below.
    policy.style_src   :self, :https, :unsafe_inline
  end

  # Inline <script> tags the app renders itself carry this nonce; anything an
  # attacker manages to inject into the page does not, so it will not execute.
  # Generated per response rather than from the session id, which is empty until
  # a session exists -- that yielded an empty nonce on the login page, which any
  # injected script could have matched.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Enforcing by default. Set CSP_REPORT_ONLY=true to fall back to reporting
  # while diagnosing a violation.
  config.content_security_policy_report_only = ENV.fetch("CSP_REPORT_ONLY", "false") == "true"
end
