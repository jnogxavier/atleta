class CreateAdminAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_audit_logs do |t|
      t.references :admin, foreign_key: { to_table: :users }, null: false
      t.references :target_user, foreign_key: { to_table: :users }, null: true
      t.string :action, null: false
      t.string :ip_address, null: false
      t.text :user_agent
      t.string :target_type
      t.text :notes

      t.timestamps
    end

    # Add indexes for common queries
    add_index :admin_audit_logs, [ :admin_id, :created_at ]
    add_index :admin_audit_logs, [ :target_user_id, :created_at ]
    add_index :admin_audit_logs, [ :action, :created_at ]
    add_index :admin_audit_logs, :created_at
  end
end
