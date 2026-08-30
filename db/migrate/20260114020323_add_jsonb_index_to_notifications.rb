class AddJsonbIndexToNotifications < ActiveRecord::Migration[8.1]
  def change
    # Add GIN index for efficient JSONB queries on notification metadata
    add_index :notifications, :metadata, using: :gin, if_not_exists: true
  end
end
