# frozen_string_literal: true

class StudentQueryService
  DEFAULT_LIMIT = 10
  MAX_QUERY_LENGTH = 100

  # Fetch student profiles for autocomplete/search
  # @param search_query [String] Search term for name or email
  # @param include_inactive [Boolean] Whether to include expired profiles
  # @param limit [Integer] Maximum number of results
  # @return [Array] Array of student data hashes
  def self.fetch_students(search_query: nil, include_inactive: false, limit: DEFAULT_LIMIT)
    return [] if search_query&.length.to_i > MAX_QUERY_LENGTH

    query = User.joins(:student_profile)
                .where(role: "student")
                .select("student_profiles.id, student_profiles.name, student_profiles.expires_at, users.email_address")
                .order("student_profiles.name")

    query = query.where("student_profiles.expires_at IS NULL OR student_profiles.expires_at > ?", Time.zone.today) unless include_inactive

    if search_query.present?
      normalized_query = build_search_query(search_query)
      query = query.where(
        "unaccent(LOWER(student_profiles.name)) ILIKE unaccent(?) OR unaccent(LOWER(users.email_address)) ILIKE unaccent(?)",
        normalized_query,
        normalized_query
      )
    end

    query.limit(limit).map { |u| format_student_data(u) }
  end

  private

  def self.build_search_query(search_string)
    ApplicationHelper.build_search_query(search_string)
  end

  def self.format_student_data(user)
    {
      id: user.id,
      name: user.name,
      email: user.email_address,
      active: user.expires_at.blank? || user.expires_at > Time.zone.today
    }
  end
end
