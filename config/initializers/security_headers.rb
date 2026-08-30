# Configure security headers for all responses
# Protects against common web vulnerabilities

Rails.application.config.action_dispatch.default_headers = {
  # Prevent browsers from interpreting content types other than declared
  # Stops attackers from executing scripts embedded in CSS/images
  "X-Content-Type-Options" => "nosniff",

  # Prevent page from being displayed in an iframe on other sites
  # Protects against clickjacking attacks
  "X-Frame-Options" => "DENY",

  # Enable XSS protection in older browsers that support it
  # Modern browsers use CSP instead, but this is a safety net
  "X-XSS-Protection" => "1; mode=block",

  # Control how much referrer information is shared with external sites
  # strict-origin-when-cross-origin: only send origin for cross-site requests
  "Referrer-Policy" => "strict-origin-when-cross-origin"
}

# Additional security configuration
if Rails.env.production?
  # Enable HSTS (HTTP Strict Transport Security)
  # Forces browser to always use HTTPS for this domain
  Rails.application.config.ssl_options = {
    hsts: {
      expires: 31_536_000,  # 1 year in seconds
      include_subdomains: true,
      preload: true
    }
  }
end
