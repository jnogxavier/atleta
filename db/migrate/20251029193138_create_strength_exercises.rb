class CreateStrengthExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :strength_exercises do |t|
      t.string :name
      t.string :muscle_group
      t.string :equipment
      t.string :video_url
      t.text :description

      t.timestamps
    end
  end
end
