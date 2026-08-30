class TrainingPdfPresenter
  attr_reader :training, :student_profile

  def initialize(training, student_profile)
    @training = training
    @student_profile = student_profile
  end

  def training_name
    training.name
  end

  def training_day
    training.day
  end

  def student_name
    student_profile.user.name || student_profile.user.email_address
  end

  def training_description
    training.description
  end

  def training_notes
    training.notes
  end

  def exercise_sections
    sections = []

    sections << build_section("Treino de Força", training.training_strength_exercises, [ :sets, :reps ]) if training.training_strength_exercises.any?
    sections << build_section("Treino de Mobilidade", training.training_mobility_exercises, [ :sets, :duration ]) if training.training_mobility_exercises.any?
    sections << build_section("Treino de Core", training.training_core_exercises, [ :sets, :reps ]) if training.training_core_exercises.any?
    sections << build_section("Treino Cardio", training.training_cardio_exercises, [ :duration, :calories ]) if training.training_cardio_exercises.any?

    sections
  end

  private

  def build_section(title, exercises, columns)
    {
      title: title,
      columns: columns,
      exercises: exercises.map { |ex| exercise_data(ex) }.compact
    }
  end

  def exercise_data(training_exercise)
    exercise = get_exercise(training_exercise)
    return nil unless exercise

    case training_exercise
    when TrainingStrengthExercise
      {
        name: exercise.name,
        sets: training_exercise.sets || "-",
        reps: training_exercise.reps || "-",
        notes: training_exercise.notes || "-"
      }
    when TrainingMobilityExercise
      {
        name: exercise.name,
        sets: training_exercise.sets || "-",
        duration: training_exercise.duration || "-",
        notes: training_exercise.notes || "-"
      }
    when TrainingCoreExercise
      {
        name: exercise.name,
        sets: training_exercise.sets || "-",
        reps: training_exercise.reps || "-",
        notes: training_exercise.notes || "-"
      }
    when TrainingCardioExercise
      {
        name: exercise.name,
        duration: training_exercise.duration || "-",
        calories: training_exercise.calories || "-",
        notes: training_exercise.notes || "-"
      }
    end
  end

  def get_exercise(training_exercise)
    case training_exercise
    when TrainingStrengthExercise
      training_exercise.strength_exercise
    when TrainingMobilityExercise
      training_exercise.mobility_exercise
    when TrainingCoreExercise
      training_exercise.core_exercise
    when TrainingCardioExercise
      training_exercise.cardio_exercise
    end
  end
end
