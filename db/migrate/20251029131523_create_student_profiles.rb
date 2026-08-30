class CreateStudentProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :student_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :student_id
      t.string :gender
      t.string :plan
      t.date :start_date
      t.date :expires_at
      t.string :status, default: "active"
      t.decimal :value, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
    add_index :student_profiles, :student_id, unique: true
  end
end
