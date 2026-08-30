class CreateCardioExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :cardio_exercises do |t|
      t.string :name
      t.string :cardio_type
      t.string :video_url
      t.text :description

      t.timestamps
    end
  end
end
