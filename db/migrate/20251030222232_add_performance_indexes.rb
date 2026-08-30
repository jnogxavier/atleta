class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Index for trainings.active - frequently queried by active_trainings scope
    add_index :trainings, :active unless index_exists?(:trainings, :active)

    # Index for notifications.read_at - frequently queried by unread/read scopes
    add_index :notifications, :read_at unless index_exists?(:notifications, :read_at)

    # Index for notifications.notification_type - used by by_type scope
    add_index :notifications, :notification_type unless index_exists?(:notifications, :notification_type)

    # Composite index for evaluation_media - often filtered by evaluated AND media_type
    add_index :evaluation_media, [ :evaluated, :media_type ] unless index_exists?(:evaluation_media, [ :evaluated, :media_type ])

    # Index for evaluation_media.user_id - frequently joined on user
    add_index :evaluation_media, :user_id unless index_exists?(:evaluation_media, :user_id)
  end
end
