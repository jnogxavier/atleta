class AddStatusFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :deactivation_reason, :text
    add_column :users, :deactivated_at, :datetime
    add_column :users, :deactivated_by_id, :integer
    add_column :users, :activation_reason, :text
    add_column :users, :activated_at, :datetime
    add_column :users, :activated_by_id, :integer
  end
end
