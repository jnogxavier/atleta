class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :name
      t.integer :role, default: 1, null: false
      t.integer :registration_status, default: 0, null: false
      t.boolean :terms_accepted, default: false, null: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, :registration_status
  end
end
