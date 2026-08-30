class StudentProfile < ApplicationRecord
  belongs_to :user
  has_many :trainings, dependent: :destroy
  has_many :workout_sessions, dependent: :destroy
  has_many :nutrition_plans, dependent: :destroy
  has_many :videos, as: :videoable, dependent: :destroy

  accepts_nested_attributes_for :user

  enum :status, { active: "active", inactive: "inactive", suspended: "suspended" }, default: :active

  validates :name, presence: true
  validates :student_id, uniqueness: true, allow_nil: true

  scope :not_rejected, -> { where(rejected: false) }
  scope :rejected_students, -> { where(rejected: true) }

  before_create :generate_student_id
  before_save :sync_name_from_user

  private

  def generate_student_id
    # Prevent infinite loop by limiting attempts
    # With 8 alphanumeric chars (62^8), collision probability is negligible
    max_attempts = 10
    attempts = 0

    loop do
      self.student_id = SecureRandom.alphanumeric(8).upcase
      break unless StudentProfile.exists?(student_id: student_id)

      attempts += 1
      if attempts >= max_attempts
        raise "Failed to generate unique student_id after #{max_attempts} attempts"
      end
    end
  end

  def sync_name_from_user
    self.name = user.name if user&.name.present?
  end

  public

  def currently_active?
    active? && (expires_at.nil? || expires_at > Time.zone.today)
  end

  def expired?
    expires_at.present? && expires_at <= Time.zone.today
  end

  def active_trainings
    trainings.active_trainings
  end

  def active_nutrition_plans
    nutrition_plans.active
  end

  def current_workout_session(training)
    workout_sessions.in_progress.find_by(training: training)
  end

  def start_workout_session(training)
    WorkoutSessionService.initialize_workout_session(self, training)
  end
end
