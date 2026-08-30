require "rails_helper"

# The Mission Control Jobs dashboard is mounted at /admin/jobs behind
# AdminSessionConstraint: only a signed-in admin matches the route; everyone
# else falls through to a 404.
RSpec.describe "Mission Control Jobs access", type: :request do
  def login(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  it "returns 404 for an unauthenticated visitor" do
    get "/admin/jobs"
    expect(response).to have_http_status(:not_found)
  end

  it "returns 404 for a signed-in non-admin" do
    login(create(:user, :student))
    get "/admin/jobs"
    expect(response).to have_http_status(:not_found)
  end

  it "renders the dashboard for a signed-in admin" do
    login(create(:user, :admin))
    get "/admin/jobs"
    expect(response).to have_http_status(:ok)
  end
end
