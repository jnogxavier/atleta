# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  # Default view - minimal user info
  def default
    attributes(
      id: object.id,
      email_address: object.email_address,
      role: object.role
    )
  end

  # Detailed view - full user info with timestamps
  def detailed
    attributes(
      id: object.id,
      email_address: object.email_address,
      role: object.role,
      registration_complete: object.registration_complete,
      created_at: object.created_at,
      updated_at: object.updated_at
    )
  end

  # Admin view - includes all details
  def admin
    detailed.merge(
      password_updated_at: object.password_updated_at
    )
  end

  # Summary - just ID and email
  def summary
    attributes(
      id: object.id,
      email_address: object.email_address
    )
  end
end
