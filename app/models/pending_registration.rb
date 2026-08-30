class PendingRegistration < ApplicationRecord
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :rejected_by, class_name: "User", optional: true

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, default: :pending

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :phone, presence: true, phone: true

  scope :pending_only, -> { where(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }

  def approve!(admin_user)
    transaction do
      update!(status: "approved", approved_at: Time.current, approved_by: admin_user)
    end
  end

  def reject!(admin_user, rejection_notes = nil)
    transaction do
      update!(
        status: "rejected",
        rejected_at: Time.current,
        rejected_by: admin_user,
        notes: rejection_notes || notes
      )
    end
  end

  def reset_to_pending!
    transaction do
      update!(
        status: "pending",
        approved_at: nil,
        approved_by: nil,
        rejected_at: nil,
        rejected_by: nil
      )
    end
  end

  def approved?
    status == "approved"
  end

  def rejected?
    status == "rejected"
  end

  def pending?
    status == "pending"
  end
end
