class AdminAuditLog < ApplicationRecord
  belongs_to :admin, class_name: "User"
  belongs_to :target_user, class_name: "User", optional: true

  enum :action, {
    view_student_data: "view_student_data",
    view_personal_data: "view_personal_data",
    edit_user: "edit_user",
    deactivate_user: "deactivate_user",
    activate_user: "activate_user",
    approve_registration: "approve_registration",
    reject_registration: "reject_registration",
    reset_password: "reset_password",
    update_training: "update_training",
    delete_training: "delete_training",
    create_nutrition_plan: "create_nutrition_plan",
    update_nutrition_plan: "update_nutrition_plan",
    delete_nutrition_plan: "delete_nutrition_plan"
  }, prefix: true

  validates :admin_id, :action, :ip_address, presence: true
  validates :target_user_id, presence: true, if: -> { target_type == "User" }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_admin, ->(admin_id) { where(admin_id: admin_id) }
  scope :by_target_user, ->(user_id) { where(target_user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :since, ->(time) { where("created_at >= ?", time) }
end
