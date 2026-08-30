class CreateVideos < ActiveRecord::Migration[8.1]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :category
      t.string :url
      t.string :duration
      t.text :description
      t.string :thumbnail_url
      t.references :videoable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
