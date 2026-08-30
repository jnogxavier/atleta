# frozen_string_literal: true

class StudentProfileSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      student_id: object.student_id,
      name: object.name,
      user_name: object.user&.name,
      status: object.status,
      expires_at: object.expires_at
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      student_id: object.student_id,
      name: object.name,
      status: object.status
    )
  end

  # Detailed view - full info with calculated fields and associations
  def detailed
    attributes(
      id: object.id,
      student_id: object.student_id,
      name: object.name,
      status: object.status,
      expires_at: object.expires_at,
      start_date: object.start_date,
      value: object.value,
      active: object.currently_active?,
      days_until_expiration: days_until_expiration,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      user: serialize_association(object.user, UserSerializer, view: :summary),
      trainings_count: object.trainings.count,
      nutrition_plans_count: object.nutrition_plans.count
    )
  end

  # Admin view - administrative details
  def admin
    attributes(
      id: object.id,
      student_id: object.student_id,
      name: object.name,
      status: object.status,
      expires_at: object.expires_at,
      start_date: object.start_date,
      value: object.value,
      active: object.currently_active?,
      days_until_expiration: days_until_expiration,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      user: serialize_association(object.user, UserSerializer, view: :admin)
    )
  end

  private

  # Calculate days until plan expiration
  def days_until_expiration
    return nil unless object.expires_at.present?
    (object.expires_at - Date.today).to_i
  end
end
