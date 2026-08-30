class AudioRecording < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :file, presence: true, if: -> { persisted? }

  validate :audio_file_valid, if: -> { file.attached? }

  private

  def audio_file_valid
    if file.attached?
      # Validate content type
      allowed_types = %w[audio/webm audio/mpeg audio/mp4 audio/wav]
      unless allowed_types.include?(file.blob.content_type)
        errors.add(:file, "must be a valid audio format (WebM, MP3, MP4, or WAV)")
      end

      # Validate file size
      if file.blob.byte_size > 25.megabytes
        errors.add(:file, "must be less than 25MB")
      end
    end
  end

  def file_url
    file.attached? ? Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true) : nil
  end

  def file_size_mb
    file.attached? ? (file.blob.byte_size / 1024.0 / 1024.0).round(2) : 0
  end
end
