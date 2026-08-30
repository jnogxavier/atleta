require "rails_helper"

# Regression guard: a signed-in student must not reach another student's
# records. Each of these paths had its own hand-written ownership check before
# the policies existed, so this asserts the behaviour end-to-end rather than
# trusting that every controller remembered to call `authorize`.
RSpec.describe "tenant isolation", type: :request do
  let(:intruder) { create(:user, role: "student") }
  let(:victim)   { create(:user, role: "student") }
  let(:victim_profile) { create(:student_profile, user: victim) }

  before do
    create(:student_profile, user: intruder)
    sign_in intruder
  end

  it "refuses another student's training" do
    training = create(:training, student_profile: victim_profile)

    get student_training_path(training)

    expect(response).not_to have_http_status(:ok)
    expect(response).to redirect_to(student_dashboard_path)
  end

  it "refuses another student's nutrition plan" do
    plan = create(:nutrition_plan, student_profile: victim_profile)

    get student_nutrition_plan_path(plan)

    expect(response).not_to have_http_status(:ok)
    expect(response).to redirect_to(student_dashboard_path)
  end

  it "refuses to toggle another student's workout exercise, and leaves it unchanged" do
    session = create(:workout_session, student_profile: victim_profile)
    exercise = create(:workout_session_exercise, workout_session: session, completed: false)

    patch toggle_workout_session_exercise_path(exercise)

    expect(response).to redirect_to(student_dashboard_path)
    expect(exercise.reload.completed).to be(false)
  end

  it "refuses another student's training through the top-level route" do
    training = create(:training, student_profile: victim_profile)

    get training_path(training)

    expect(response).not_to have_http_status(:ok)
  end
end
