class EvaluationMedium < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :media_type, presence: true, inclusion: { in: %w[photo video] }
  validates :file_url, presence: true, unless: -> { file.attached? }

  # Custom validations for file uploads
  validate :validate_file_if_present

  scope :photos, -> { where(media_type: "photo") }
  scope :videos, -> { where(media_type: "video") }
  scope :pending_evaluation, -> { where(evaluated: false) }
  scope :evaluated, -> { where(evaluated: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :grouped_by_upload_date, -> {
    group_by { |media| media.uploaded_at.to_date }.sort.reverse
  }

  def photo?
    media_type == "photo"
  end

  def video?
    media_type == "video"
  end

  def file_url_or_attachment
    if file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
    else
      file_url
    end
  end

  private

  def validate_file_if_present
    return unless file.attached?

    # Validate file size
    if file.blob.byte_size > 500.megabytes
      errors.add(:file, "must be less than 500MB")
      return
    end

    # Validate file content type
    content_type = file.blob.content_type

    case media_type
    when "photo"
      unless content_type.match?(/image\/(jpeg|png)/)
        errors.add(:file, "must be a JPEG or PNG image for photo uploads")
      end
    when "video"
      unless content_type.match?(/video\/(mp4|quicktime)/)
        errors.add(:file, "must be an MP4 or MOV video for video uploads")
      end
    end
  end
end
