class FixVideoMigrationWithSql < ActiveRecord::Migration[8.1]
  def change
    # Migrate strength_exercises
    execute <<-SQL
      INSERT INTO videos (videoable_type, videoable_id, url, created_at, updated_at)
      SELECT 'StrengthExercise', id, video_url, NOW(), NOW()
      FROM strength_exercises
      WHERE video_url IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM videos
        WHERE videos.videoable_type = 'StrengthExercise'
        AND videos.videoable_id = strength_exercises.id
      )
    SQL

    # Migrate mobility_exercises
    execute <<-SQL
      INSERT INTO videos (videoable_type, videoable_id, url, created_at, updated_at)
      SELECT 'MobilityExercise', id, video_url, NOW(), NOW()
      FROM mobility_exercises
      WHERE video_url IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM videos
        WHERE videos.videoable_type = 'MobilityExercise'
        AND videos.videoable_id = mobility_exercises.id
      )
    SQL

    # Migrate core_exercises
    execute <<-SQL
      INSERT INTO videos (videoable_type, videoable_id, url, created_at, updated_at)
      SELECT 'CoreExercise', id, video_url, NOW(), NOW()
      FROM core_exercises
      WHERE video_url IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM videos
        WHERE videos.videoable_type = 'CoreExercise'
        AND videos.videoable_id = core_exercises.id
      )
    SQL

    # Migrate cardio_exercises
    execute <<-SQL
      INSERT INTO videos (videoable_type, videoable_id, url, created_at, updated_at)
      SELECT 'CardioExercise', id, video_url, NOW(), NOW()
      FROM cardio_exercises
      WHERE video_url IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM videos
        WHERE videos.videoable_type = 'CardioExercise'
        AND videos.videoable_id = cardio_exercises.id
      )
    SQL
  end
end
