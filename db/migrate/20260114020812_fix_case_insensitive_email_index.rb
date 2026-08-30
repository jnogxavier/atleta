class FixCaseInsensitiveEmailIndex < ActiveRecord::Migration[8.1]
  def change
    # Remove the old case-sensitive index
    remove_index :users, :email_address, if_exists: true

    # Add case-insensitive index using LOWER function
    # This prevents duplicate emails with different cases (e.g., user@example.com and USER@EXAMPLE.COM)
    add_index :users, "LOWER(email_address)", unique: true, name: "index_users_on_lower_email_address"
  end
end
