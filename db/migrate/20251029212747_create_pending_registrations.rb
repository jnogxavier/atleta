class CreatePendingRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :pending_registrations do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :phone, null: false
      t.string :status, default: 'pending'
      t.text :notes
      t.datetime :approved_at
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :rejected_at
      t.references :rejected_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :pending_registrations, :email, unique: true
    add_index :pending_registrations, :status
  end
end
