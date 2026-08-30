class WorkoutSession < ApplicationRecord
  belongs_to :student_profile
  belongs_to :training

  has_many :workout_session_exercises, dependent: :destroy

  validates :training, presence: true
  validates :student_profile, presence: true

  enum :difficulty, { facil: 1, medio: 2, dificil: 3, muito_dificil: 4 }, prefix: true

  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_initialize :set_defaults

  def completed?
    completed_at.present?
  end

  def complete!
    update(completed_at: Time.current)
  end

  def progress_percentage
    # Avoid N+1 by calculating in single query using group
    # Returns a hash like {true => 5, false => 3}
    counts = workout_session_exercises.group(:completed).count
    total = counts.values.sum

    return 0 if total.zero?

    completed = counts[true] || 0
    (completed.to_f / total * 100).round
  end

  def in_progress?
    !completed?
  end

  def add_cycle(duration_seconds)
    # Validate duration is a positive number
    unless duration_seconds.is_a?(Numeric) && duration_seconds > 0
      raise ArgumentError, "Duration must be a positive number, got: #{duration_seconds.inspect}"
    end

    self.cycles ||= []
    self.cycles << {
      started_at: Time.current.iso8601,
      duration: duration_seconds
    }
    save!
  end

  def current_cycle_start
    return nil if cycles.blank?
    Time.parse(cycles.last["started_at"])
  end

  def total_duration
    return 0 if cycles.blank?
    cycles.sum { |c| c["duration"] || 0 }
  end

  def cycles_count
    cycles&.size || 0
  end

  private

  def set_defaults
    self.cycles ||= []
  end
end
