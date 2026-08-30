class AddPasswordExpirationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_expires_at, :datetime
  end
end
