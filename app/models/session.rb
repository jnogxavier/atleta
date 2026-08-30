class Session < ApplicationRecord
  belongs_to :user

  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :active, -> { where("expires_at >= ?", Time.current) }

  before_create :set_expiration

  private

  def set_expiration
    self.expires_at ||= 30.days.from_now
  end
end
