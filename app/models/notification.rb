class Notification < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }

  TYPES = {
    info: "info",
    success: "success",
    warning: "warning",
    error: "error",
    expiration: "expiration",
    training: "training",
    anamnese: "anamnese"
  }.freeze

  def mark_as_read!
    update(read_at: Time.current)
  end

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def self.create_expiration_notice(student_profile)
    return unless student_profile.expires_at.present?

    days_until = (student_profile.expires_at.to_date - Date.current).to_i
    return unless days_until <= 15 && days_until >= 0

    create!(
      user: student_profile.user,
      title: "Seu plano está próximo do vencimento",
      message: "Seu plano vence em #{days_until} dias (#{I18n.l(student_profile.expires_at)}). Entre em contato para renovar.",
      notification_type: "expiration",
      action_url: "/student/dashboard"
    )
  end

  def self.create_training_assigned(training)
    create!(
      user: training.student_profile.user,
      title: "Novo treino disponível",
      message: "O treino '#{training.name}' foi atribuído a você. Comece agora!",
      notification_type: "training",
      action_url: "/trainings",
      metadata: { training_id: training.id }
    )
  end
end
