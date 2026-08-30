# frozen_string_literal: true

class TrainingSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      name: object.name,
      day: object.day,
      active: object.active,
      student_name: object.student_profile.name
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      name: object.name,
      day: object.day
    )
  end

  # List view - for paginated lists
  def list
    attributes(
      id: object.id,
      name: object.name,
      day: object.day,
      active: object.active
    ).merge(
      student_name: object.student_profile.name,
      total_exercises: object.total_exercises
    )
  end

  # Detailed view - full info with exercises and associations
  def detailed
    attributes(
      id: object.id,
      name: object.name,
      day: object.day,
      description: object.description,
      notes: object.notes,
      active: object.active,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      student_profile_id: object.student_profile_id,
      student_name: object.student_profile.name,
      total_exercises: object.total_exercises,
      student_profile: serialize_association(object.student_profile, StudentProfileSerializer, view: :summary)
    ).merge(serialize_exercises)
  end

  # Admin view - administrative details
  def admin
    attributes(
      id: object.id,
      name: object.name,
      day: object.day,
      description: object.description,
      notes: object.notes,
      active: object.active,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      student_name: object.student_profile.name,
      total_exercises: object.total_exercises,
      student_profile: serialize_association(object.student_profile, StudentProfileSerializer, view: :admin)
    )
  end

  private

  # Keys are flat (strength_exercises, ...) and each item is keyed by the
  # underlying exercise id, not the join-record id: that is the shape
  # training_form_controller.js reads back when populating the edit form.
  def serialize_exercises
    {
      strength_exercises: serialize_collection(
        object.training_strength_exercises,
        TrainingStrengthExerciseSerializer,
        view: :form
      ),
      mobility_exercises: serialize_collection(
        object.training_mobility_exercises,
        TrainingMobilityExerciseSerializer,
        view: :form
      ),
      core_exercises: serialize_collection(
        object.training_core_exercises,
        TrainingCoreExerciseSerializer,
        view: :form
      ),
      cardio_exercises: serialize_collection(
        object.training_cardio_exercises,
        TrainingCardioExerciseSerializer,
        view: :form
      )
    }
  end
end
