class CreateCoreExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :core_exercises do |t|
      t.string :name
      t.string :category
      t.string :video_url
      t.text :description

      t.timestamps
    end
  end
end
