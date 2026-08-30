require "rails_helper"

# Covers toggling a workout-session exercise's completion, including the
# ownership gate in WorkoutSessionExercisesController.
RSpec.describe "Workout session exercises", type: :request do
  def login(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  let(:student_user) { create(:user, :student) }
  let(:student_profile) { create(:student_profile, user: student_user) }
  let(:training) { create(:training, student_profile: student_profile) }
  let(:workout_session) { create(:workout_session, student_profile: student_profile, training: training) }
  let(:exercise) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }

  describe "PATCH /workout_session_exercises/:id/toggle" do
    it "toggles completion for the owner" do
      login(student_user)

      # Send a Referer so redirect_back returns there rather than the fallback.
      patch toggle_workout_session_exercise_path(exercise),
            headers: { "HTTP_REFERER" => student_dashboard_path }

      expect(response).to have_http_status(:redirect)
      expect(exercise.reload.completed).to be(true)
    end

    it "blocks a student who does not own the session and does not toggle it" do
      intruder = create(:user, :student)
      create(:student_profile, user: intruder)
      login(intruder)

      patch toggle_workout_session_exercise_path(exercise),
            headers: { "HTTP_REFERER" => student_dashboard_path }

      # Denied requests now land on the user's own dashboard rather than root.
      # root_path only redirects to /login, which bounces a signed-in student
      # back to this same page, so this is the same destination minus a hop.
      expect(response).to redirect_to(student_dashboard_path)
      expect(exercise.reload.completed).to be(false)
    end
  end
end
