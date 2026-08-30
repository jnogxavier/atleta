# frozen_string_literal: true

class MobilityExerciseSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      name: object.name,
      region: object.region
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      name: object.name,
      region: object.region
    )
  end

  # Detailed view - full info with description and videos
  def detailed
    attributes(
      id: object.id,
      name: object.name,
      description: object.description,
      region: object.region,
      video_url: object.video_url,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      total_videos: object.videos.count,
      videos: serialize_collection(object.videos, VideoSerializer, view: :default)
    )
  end

  # Admin view - administrative details
  def admin
    detailed
  end
end
