class AddRejectedToStudentProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :student_profiles, :rejected, :boolean, default: false, null: false
    add_column :student_profiles, :rejected_at, :datetime
    add_column :student_profiles, :rejection_reason, :text
  end
end
