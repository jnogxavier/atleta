require "rails_helper"

# Covers viewing training details:
#   - the top-level TrainingsController#show (scoped find -> 404 for a training
#     that isn't the current student's)
#   - the Student::TrainingsController#show (redirects a non-owner to the dashboard)
RSpec.describe "Trainings", type: :request do
  def login(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  let(:student_user) { create(:user, :student) }
  let(:student_profile) { create(:student_profile, user: student_user) }

  describe "GET /trainings/:id (TrainingsController#show)" do
    it "renders the student's own training" do
      training = create(:training, student_profile: student_profile)
      login(student_user)

      get training_path(training)
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for a training that is not the student's" do
      student_profile # the logged-in student has their own profile/scope
      other_training = create(:training, student_profile: create(:student_profile))
      login(student_user)

      get training_path(other_training)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /student/trainings/:id (Student::TrainingsController#show)" do
    it "renders the student's own training" do
      training = create(:training, student_profile: student_profile)
      login(student_user)

      get student_training_path(training)
      expect(response).to have_http_status(:ok)
    end

    it "redirects a non-owner to the student dashboard" do
      other_training = create(:training, student_profile: create(:student_profile))
      login(student_user)

      get student_training_path(other_training)
      expect(response).to redirect_to(student_dashboard_path)
    end
  end
end
