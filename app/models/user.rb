class User < ApplicationRecord
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy
  has_one :student_profile, dependent: :destroy
  has_one :partner_profile, dependent: :destroy
  has_one :anamnese, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :evaluation_media, dependent: :destroy
  has_one :audio_recording, dependent: :destroy
  accepts_nested_attributes_for :anamnese
  accepts_nested_attributes_for :student_profile
  accepts_nested_attributes_for :partner_profile

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { admin: 0, student: 1, partner: 2 }, default: :student
  enum :registration_status, { draft: 0, complete: 1 }, default: :draft

  validates :email_address, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, presence: { message: "não pode ficar em branco" },
            length: { minimum: 8, message: "deve ter no mínimo 8 caracteres" },
            confirmation: { message: "não coincide" },
            if: -> { password.present? }
  validates :password_digest, presence: true, if: -> { complete? }
  validates :terms_accepted, acceptance: { message: "deve ser aceito" },
            if: -> { complete? }
  validate :password_not_expired, if: -> { password.present? && password_expires_at.present? }

  def admin?
    role == "admin"
  end

  def student?
    role == "student"
  end

  def partner?
    role == "partner"
  end

  def display_role
    role.titleize
  end

  def profile
    case role
    when "student"
      student_profile
    when "partner"
      partner_profile
    else
      nil
    end
  end

  def password_expired?
    password_expires_at.present? && password_expires_at <= Time.current
  end

  def set_temporary_password_expiration(hours = 24)
    self.password_expires_at = Time.current + hours.hours
  end

  def clear_password_expiration
    self.password_expires_at = nil
  end

  private

  def password_not_expired
    if password_expired?
      errors.add(:password, "reset link has expired. Please request a new one.")
    end
  end
end
