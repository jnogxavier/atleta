require "rails_helper"

# These policies carry the ownership rule the controllers used to each
# re-implement: a student reaches only their own records, an admin reaches any.
RSpec.describe "ownership policies" do
  let(:owner)     { create(:user, role: "student") }
  let(:intruder)  { create(:user, role: "student") }
  let(:admin)     { create(:user, role: "admin") }
  let(:profile)   { create(:student_profile, user: owner) }

  describe TrainingPolicy do
    let(:training) { create(:training, student_profile: profile) }

    it "lets the owning student read it" do
      expect(described_class.new(owner, training).show?).to be true
    end

    it "refuses another student" do
      expect(described_class.new(intruder, training).show?).to be false
    end

    it "allows an admin" do
      expect(described_class.new(admin, training).show?).to be true
    end

    it "refuses an anonymous visitor" do
      expect(described_class.new(nil, training).show?).to be false
    end
  end

  describe NutritionPlanPolicy do
    let(:plan) { create(:nutrition_plan, student_profile: profile) }

    it "lets the owning student read it" do
      expect(described_class.new(owner, plan).show?).to be true
    end

    it "refuses another student" do
      expect(described_class.new(intruder, plan).show?).to be false
    end

    it "allows an admin" do
      expect(described_class.new(admin, plan).show?).to be true
    end
  end

  describe WorkoutSessionExercisePolicy do
    let(:session)  { create(:workout_session, student_profile: profile) }
    let(:exercise) { create(:workout_session_exercise, workout_session: session) }

    it "lets the owning student toggle it" do
      expect(described_class.new(owner, exercise).toggle?).to be true
    end

    it "refuses another student" do
      expect(described_class.new(intruder, exercise).toggle?).to be false
    end

    it "allows an admin" do
      expect(described_class.new(admin, exercise).toggle?).to be true
    end
  end

  describe ApplicationPolicy do
    it "denies every action by default so an incomplete policy fails closed" do
      policy = described_class.new(admin, Object.new)

      expect(policy.index?).to be false
      expect(policy.show?).to be false
      expect(policy.create?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end
  end
end
