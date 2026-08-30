class NutritionPlanPolicy < ApplicationPolicy
  def show?
    owner_or_admin?(record.student_profile)
  end

  def index?
    user.present?
  end
end
