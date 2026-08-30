# frozen_string_literal: true

class TrainingCardioExerciseSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      position: object.position,
      duration: object.duration,
      calories: object.calories,
      intensity: object.intensity,
      notes: object.notes
    ).merge(
      exercise_name: object.cardio_exercise.name,
      exercise_id: object.cardio_exercise_id
    )
  end

  # Form view - shape consumed by the training edit form
  def form
    attributes(
      id: object.cardio_exercise_id,
      name: object.cardio_exercise.name,
      duration: object.duration,
      intensity: object.intensity,
      notes: object.notes,
      order: object.position
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      position: object.position,
      duration: object.duration,
      calories: object.calories,
      intensity: object.intensity
    ).merge(
      exercise_name: object.cardio_exercise.name
    )
  end

  # Detailed view - full info with exercise details
  def detailed
    attributes(
      id: object.id,
      position: object.position,
      duration: object.duration,
      calories: object.calories,
      intensity: object.intensity,
      notes: object.notes,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      exercise: serialize_association(
        object.cardio_exercise,
        CardioExerciseSerializer,
        view: :detailed
      )
    )
  end

  # Admin view - administrative details
  def admin
    detailed.merge(
      training_id: object.training_id
    )
  end
end
