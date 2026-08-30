require "rails_helper"

# Covers the nutrition-plan journeys:
#   - a student may view their OWN plan, but is blocked from another student's
#   - an admin may create a plan and toggle its active flag
RSpec.describe "Nutrition plans", type: :request do
  def login(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end

  describe "student viewing plans" do
    let(:student_user) { create(:user, :student) }
    let(:student_profile) { create(:student_profile, user: student_user) }

    it "renders the student's own plan" do
      plan = create(:nutrition_plan, student_profile: student_profile)
      login(student_user)

      get student_nutrition_plan_path(plan)
      expect(response).to have_http_status(:ok)
    end

    it "blocks access to another student's plan" do
      other_profile = create(:student_profile)
      other_plan = create(:nutrition_plan, student_profile: other_profile)
      login(student_user)

      get student_nutrition_plan_path(other_plan)
      expect(response).to redirect_to(student_dashboard_path)
    end
  end

  describe "admin managing plans" do
    let(:admin_user) { create(:user, :admin) }
    let(:student_profile) { create(:student_profile) }

    it "creates a plan (happy path)" do
      login(admin_user)

      expect {
        post admin_nutrition_plans_path, params: {
          nutrition_plan: {
            student_profile_id: student_profile.id,
            name: "Plano de Emagrecimento",
            description: "Plano focado em deficit calorico",
            active: true
          }
        }
      }.to change(NutritionPlan, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path(tab: "nutrition"))
      plan = NutritionPlan.order(:created_at).last
      expect(plan.name).to eq("Plano de Emagrecimento")
      expect(plan.student_profile_id).to eq(student_profile.id)
    end

    it "toggles the active flag" do
      plan = create(:nutrition_plan, student_profile: student_profile, active: true)
      login(admin_user)

      patch toggle_active_admin_nutrition_plan_path(plan)

      expect(plan.reload.active).to be(false)
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
