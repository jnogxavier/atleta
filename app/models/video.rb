class Video < ApplicationRecord
  belongs_to :videoable, polymorphic: true

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }

  before_save :extract_youtube_thumbnail, if: :url_changed?

  # Title and category are derived from the associated exercise rather than
  # stored: the videos table's title/category/duration columns were removed
  # (migration 20251205235308). Views should use these helpers.
  def exercise_title
    videoable&.name
  end

  def exercise_category
    "Técnica"
  end

  def youtube_video_id
    return nil unless url.present?
    regex = /(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/
    match = url.match(regex)
    match ? match[1] : nil
  end

  def safe_url
    return nil unless url.present?

    uri = URI.parse(url)
    return nil unless %w[http https].include?(uri.scheme)

    url
  rescue URI::InvalidURIError
    nil
  end

  private

  def extract_youtube_thumbnail
    if (video_id = youtube_video_id)
      self.thumbnail_url = "https://img.youtube.com/vi/#{video_id}/mqdefault.jpg"
    end
  end
end
