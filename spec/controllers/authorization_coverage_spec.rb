require "rails_helper"

# Guards the invariant that every controller states how it is protected.
#
# The point is not to check a particular rule but to make forgetting loud: a new
# controller added with no role gate and no `authorize` call fails here rather
# than shipping open. If a controller is genuinely public it belongs in
# PUBLIC_CONTROLLERS below, which makes that a deliberate, reviewable choice.
RSpec.describe "authorization coverage" do
  # Reachable without signing in, by design.
  PUBLIC_CONTROLLERS = %w[
    ApplicationController
    SessionsController
    PasswordsController
    RegistrationsController
    Rails::HealthController
  ].freeze

  # Read-only reference catalogues shared by every role. They expose exercise
  # names and muscle groups, never anyone's data, and still sit behind
  # ApplicationController's require_authentication.
  AUTHENTICATED_ANY_ROLE_CONTROLLERS = %w[
    StrengthExercisesController
    MobilityExercisesController
    CoreExercisesController
    CardioExercisesController
  ].freeze

  # Third-party engine controllers gated at the routing layer instead: the
  # engine is mounted inside `constraints(AdminSessionConstraint)`, so a
  # non-admin never reaches them (covered by spec/requests/mission_control_jobs_spec.rb).
  ROUTE_CONSTRAINED_PREFIXES = %w[MissionControl::].freeze

  AUTHORIZATION_CONCERNS = [
    AdminAuthorization,
    StudentAuthorization,
    StudentOnlyAuthorization,
    PartnerAuthorization
  ].freeze

  def app_controllers
    Rails.application.eager_load!
    ApplicationController.descendants.reject { |c| c.name.nil? }
  end

  # Looks for a real call to Pundit's #authorize, from the action or a filter.
  #
  # Comments are stripped first: matching raw source would let a controller
  # carrying nothing but `# TODO: authorize this` pass as protected. The word
  # boundaries also keep `set_and_authorize_foo` from counting as a call.
  def calls_authorize?(controller)
    path = Rails.root.join("app/controllers/#{controller.name.underscore}.rb")
    return false unless File.exist?(path)

    code = File.readlines(path).map { |line| line.sub(/#.*/, "") }.join("\n")
    code.match?(/(^|[^\w.])authorize[ (]/)
  end

  it "protects every non-public controller with a role gate or a policy" do
    unprotected = app_controllers.reject do |controller|
      next true if PUBLIC_CONTROLLERS.include?(controller.name)
      next true if AUTHENTICATED_ANY_ROLE_CONTROLLERS.include?(controller.name)
      next true if ROUTE_CONSTRAINED_PREFIXES.any? { |prefix| controller.name.start_with?(prefix) }

      has_role_gate = AUTHORIZATION_CONCERNS.any? { |concern| controller.include?(concern) }
      has_role_gate || calls_authorize?(controller)
    end

    expect(unprotected).to be_empty, lambda {
      "These controllers declare no authorization. Add a role-gate concern, " \
      "call `authorize`, or list them in PUBLIC_CONTROLLERS if they are " \
      "intentionally public:\n  #{unprotected.map(&:name).join("\n  ")}"
    }
  end

  it "denies by default in the base policy so an incomplete policy fails closed" do
    expect(ApplicationPolicy.new(build(:user, role: "admin"), Object.new).show?).to be false
  end
end
