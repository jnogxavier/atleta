# frozen_string_literal: true

class NutritionPlanSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      name: object.name,
      active: object.active
    ).merge(
      student_name: object.student_profile.name,
      student_id: object.student_profile_id
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      name: object.name,
      active: object.active
    ).merge(
      student_name: object.student_profile.name
    )
  end

  # List view - for paginated lists
  def list
    attributes(
      id: object.id,
      name: object.name,
      active: object.active
    ).merge(
      student_name: object.student_profile.name,
      total_meals: object.meals.count
    )
  end

  # Detailed view - full info with meals
  def detailed
    nutrition_data = MealNutritionService.precompute_for_meals(object.meals)

    attributes(
      id: object.id,
      name: object.name,
      description: object.description,
      active: object.active,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      student_name: object.student_profile.name,
      student_id: object.student_profile_id,
      total_meals: object.meals.count,
      meals: serialize_collection(object.meals, MealSerializer, view: :detailed, nutrition_data: nutrition_data)
    )
  end

  # Admin view - administrative details
  def admin
    attributes(
      id: object.id,
      name: object.name,
      description: object.description,
      active: object.active,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      student_profile: serialize_association(object.student_profile, StudentProfileSerializer, view: :admin),
      total_meals: object.meals.count
    )
  end
end
