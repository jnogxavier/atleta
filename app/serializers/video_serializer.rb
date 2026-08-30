# frozen_string_literal: true

class VideoSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      url: object.url,
      description: object.description,
      videoable_type: object.videoable_type,
      videoable_id: object.videoable_id
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      url: object.url
    )
  end

  # Detailed view - full info with timestamps
  def detailed
    attributes(
      id: object.id,
      url: object.url,
      description: object.description,
      videoable_type: object.videoable_type,
      videoable_id: object.videoable_id,
      created_at: object.created_at,
      updated_at: object.updated_at
    )
  end

  # Admin view - administrative details
  def admin
    detailed
  end
end
