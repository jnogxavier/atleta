class CreateMobilityExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :mobility_exercises do |t|
      t.string :name
      t.string :region
      t.string :video_url
      t.text :description

      t.timestamps
    end
  end
end
