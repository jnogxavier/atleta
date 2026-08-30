class CreatePartnerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :partner_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :partner_id
      t.string :profession
      t.string :specialty
      t.string :status, default: "active"
      t.boolean :is_demo, default: false

      t.timestamps
    end
    add_index :partner_profiles, :partner_id, unique: true
  end
end
