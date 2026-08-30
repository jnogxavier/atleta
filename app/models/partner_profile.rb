class PartnerProfile < ApplicationRecord
  belongs_to :user

  enum :status, { active: "active", inactive: "inactive", suspended: "suspended" }, default: :active

  validates :name, presence: true
  validates :partner_id, uniqueness: true, allow_nil: true
end
