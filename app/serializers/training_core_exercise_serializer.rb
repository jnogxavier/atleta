# frozen_string_literal: true

class TrainingCoreExerciseSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      position: object.position,
      sets: object.sets,
      reps: object.reps,
      rest: object.rest,
      notes: object.notes
    ).merge(
      exercise_name: object.core_exercise.name,
      exercise_id: object.core_exercise_id
    )
  end

  # Form view - shape consumed by the training edit form
  def form
    attributes(
      id: object.core_exercise_id,
      name: object.core_exercise.name,
      sets: object.sets,
      reps: object.reps,
      rest: object.rest,
      notes: object.notes,
      order: object.position
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      position: object.position,
      sets: object.sets,
      reps: object.reps
    ).merge(
      exercise_name: object.core_exercise.name
    )
  end

  # Detailed view - full info with exercise details
  def detailed
    attributes(
      id: object.id,
      position: object.position,
      sets: object.sets,
      reps: object.reps,
      rest: object.rest,
      notes: object.notes,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      exercise: serialize_association(
        object.core_exercise,
        CoreExerciseSerializer,
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
