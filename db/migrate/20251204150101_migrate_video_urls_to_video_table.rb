class MigrateVideoUrlsToVideoTable < ActiveRecord::Migration[8.1]
  def change
    # Migrate video URLs from strength_exercises
    StrengthExercise.where.not(video_url: nil).each do |exercise|
      Video.find_or_create_by(
        videoable_type: 'StrengthExercise',
        videoable_id: exercise.id
      ) do |video|
        video.url = exercise.video_url
      end
    end

    # Migrate video URLs from mobility_exercises
    MobilityExercise.where.not(video_url: nil).each do |exercise|
      Video.find_or_create_by(
        videoable_type: 'MobilityExercise',
        videoable_id: exercise.id
      ) do |video|
        video.url = exercise.video_url
      end
    end

    # Migrate video URLs from core_exercises
    CoreExercise.where.not(video_url: nil).each do |exercise|
      Video.find_or_create_by(
        videoable_type: 'CoreExercise',
        videoable_id: exercise.id
      ) do |video|
        video.url = exercise.video_url
      end
    end

    # Migrate video URLs from cardio_exercises
    CardioExercise.where.not(video_url: nil).each do |exercise|
      Video.find_or_create_by(
        videoable_type: 'CardioExercise',
        videoable_id: exercise.id
      ) do |video|
        video.url = exercise.video_url
      end
    end
  end
end
