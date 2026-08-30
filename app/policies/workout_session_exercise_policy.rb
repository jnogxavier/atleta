class WorkoutSessionExercisePolicy < ApplicationPolicy
  # Toggling completion is a write, so it stays owner-or-admin like the reads.
  def toggle?
    owner_or_admin?(record.workout_session&.student_profile)
  end

  def update? = toggle?
end
