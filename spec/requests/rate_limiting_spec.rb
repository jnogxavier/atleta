require "rails_helper"

# Verifies the per-IP throttles on the unauthenticated auth endpoints.
RSpec.describe "Authentication rate limiting", type: :request do
  describe "login (POST /login)" do
    it "throttles after 10 attempts within the window" do
      10.times do
        post session_path, params: { email_address: "nobody@example.com", password: "wrongpass" }
      end

      post session_path, params: { email_address: "nobody@example.com", password: "wrongpass" }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq(I18n.t("flash.alerts.rate_limited"))
    end

    it "does not throttle attempts under the limit" do
      post session_path, params: { email_address: "nobody@example.com", password: "wrongpass" }

      expect(flash[:alert]).to eq(I18n.t("flash.alerts.invalid_credentials"))
    end
  end

  describe "password reset (POST /passwords)" do
    it "throttles after 5 requests within the window" do
      5.times do
        post passwords_path, params: { email_address: "nobody@example.com" }
      end

      post passwords_path, params: { email_address: "nobody@example.com" }

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to eq(I18n.t("flash.alerts.rate_limited"))
    end
  end
end
