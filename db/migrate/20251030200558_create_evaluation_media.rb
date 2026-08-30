class CreateEvaluationMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :evaluation_media do |t|
      t.references :user, null: false, foreign_key: true
      t.string :media_type, null: false
      t.string :file_url
      t.text :description
      t.string :category
      t.datetime :uploaded_at
      t.string :file_name
      t.integer :file_size
      t.boolean :evaluated, default: false
      t.text :admin_notes

      t.timestamps
    end

    add_index :evaluation_media, :evaluated
    add_index :evaluation_media, [ :evaluated, :media_type ]
    add_index :evaluation_media, [ :user_id, :created_at ]
  end
end
