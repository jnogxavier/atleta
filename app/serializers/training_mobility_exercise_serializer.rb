# frozen_string_literal: true

class TrainingMobilityExerciseSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      position: object.position,
      sets: object.sets,
      duration: object.duration,
      hold: object.hold,
      notes: object.notes
    ).merge(
      exercise_name: object.mobility_exercise.name,
      exercise_id: object.mobility_exercise_id
    )
  end

  # Form view - shape consumed by the training edit form
  def form
    attributes(
      id: object.mobility_exercise_id,
      name: object.mobility_exercise.name,
      sets: object.sets,
      duration: object.duration,
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
      duration: object.duration
    ).merge(
      exercise_name: object.mobility_exercise.name
    )
  end

  # Detailed view - full info with exercise details
  def detailed
    attributes(
      id: object.id,
      position: object.position,
      sets: object.sets,
      duration: object.duration,
      hold: object.hold,
      notes: object.notes,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      exercise: serialize_association(
        object.mobility_exercise,
        MobilityExerciseSerializer,
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
