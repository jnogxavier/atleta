# frozen_string_literal: true

class ExerciseSearchService
  ALLOWED_TYPES = %w[strength mobility core cardio].freeze
  MAX_RESULTS = 20
  MAX_QUERY_LENGTH = 100

  # Search exercises by type and query
  # @param type [String] Exercise type (strength, mobility, core, cardio)
  # @param query [String] Search query
  # @return [Array] Array of exercise hashes
  def self.search(type, query)
    return [] unless ALLOWED_TYPES.include?(type)
    return [] if query.blank? || query.to_s.length > MAX_QUERY_LENGTH

    model = exercise_model(type)
    conditions = build_conditions(type)
    normalized_query = build_search_query(query)
    params = [ normalized_query ] * field_count(type)

    model.where(conditions, *params)
         .limit(MAX_RESULTS)
         .map { |e| format_exercise(e, type) }
  end

  private

  def self.build_search_query(search_string)
    ApplicationHelper.build_search_query(search_string)
  end

  def self.exercise_model(type)
    "#{type.capitalize}Exercise".constantize
  end

  def self.build_conditions(type)
    case type
    when "strength"
      "LOWER(name) LIKE ? OR LOWER(muscle_group) LIKE ? OR LOWER(equipment) LIKE ?"
    else
      "LOWER(name) LIKE ? OR LOWER(description) LIKE ?"
    end
  end

  def self.field_count(type)
    type == "strength" ? 3 : 2
  end

  def self.format_exercise(exercise, type)
    data = { id: exercise.id, name: exercise.name, description: exercise.try(:description) }
    data.merge!(muscle: exercise.muscle_group, equipment: exercise.equipment) if type == "strength"
    data
  end
end
