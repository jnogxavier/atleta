# Base policy. Every action denies by default, so a policy that forgets to
# define a permission fails closed rather than silently allowing access.
#
# Subclasses answer per-action questions (`show?`, `update?`, ...) against
# `user` (the signed-in User, possibly nil) and `record` (the object).
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?    = false
  def show?     = false
  def create?   = false
  def new?      = create?
  def update?   = false
  def edit?     = update?
  def destroy?  = false

  private

  def admin?
    user&.admin?
  end

  # The single ownership rule this app repeats everywhere: a record reached
  # through a StudentProfile belongs to the signed-in student, and admins may
  # read anything (their access is audit-logged where it matters).
  def owned_by_user?(student_profile)
    return false if user.nil? || student_profile.nil?
    student_profile.user_id == user.id
  end

  def owner_or_admin?(student_profile)
    admin? || owned_by_user?(student_profile)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "#{self.class} must implement #resolve"
    end
  end
end
