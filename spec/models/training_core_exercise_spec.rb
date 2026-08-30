require 'rails_helper'

RSpec.describe TrainingCoreExercise, type: :model do
  describe 'associations' do
    it { should belong_to(:training) }
    it { should belong_to(:core_exercise) }
  end

  describe 'validations' do
    describe 'from TrainingExerciseValidations concern' do
      it { should validate_numericality_of(:sets).only_integer.is_greater_than(0).allow_nil }
      it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0).allow_nil }
      it { should validate_numericality_of(:rest).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    end

    describe 'specific to TrainingCoreExercise' do
      it { should validate_numericality_of(:reps).only_integer.is_greater_than(0).allow_nil }

      it 'allows nil reps' do
        exercise = build(:training_core_exercise, reps: nil)
        expect(exercise).to be_valid
      end

      it 'rejects zero reps' do
        exercise = build(:training_core_exercise, reps: 0)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:reps]).to be_present
      end

      it 'rejects negative reps' do
        exercise = build(:training_core_exercise, reps: -5)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:reps]).to be_present
      end

      it 'rejects non-integer reps' do
        exercise = build(:training_core_exercise, reps: 15.5)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:reps]).to be_present
      end
    end
  end

  describe 'callbacks' do
    describe '#normalize_reps' do
      it 'converts blank reps to nil' do
        exercise = build(:training_core_exercise)
        exercise.reps = ''
        exercise.save
        expect(exercise.reps).to be_nil
      end

      it 'keeps valid reps value' do
        exercise = build(:training_core_exercise)
        exercise.reps = 20
        exercise.save
        expect(exercise.reps.to_i).to eq(20)
      end
    end

    describe '#normalize_blank_values from concern' do
      it 'converts blank sets to nil' do
        exercise = build(:training_core_exercise)
        exercise.sets = ''
        exercise.save
        expect(exercise.sets).to be_nil
      end

      it 'converts blank rest to nil' do
        exercise = build(:training_core_exercise)
        exercise.rest = ''
        exercise.save
        expect(exercise.rest).to be_nil
      end

      it 'converts blank notes to nil' do
        exercise = build(:training_core_exercise)
        exercise.notes = ''
        exercise.save
        expect(exercise.notes).to be_nil
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      exercise = build(:training_core_exercise)
      expect(exercise).to be_valid
    end

    it 'creates a training core exercise with all attributes' do
      exercise = build(:training_core_exercise)
      exercise.assign_attributes(
        sets: 3,
        reps: 15,
        rest: 45,
        position: 2,
        notes: 'Core exercise notes')
      exercise.save!

      expect(exercise.sets).to eq(3)
      expect(exercise.reps.to_i).to eq(15)
      expect(exercise.rest.to_i).to eq(45)
      expect(exercise.position).to eq(2)
      expect(exercise.notes).to eq('Core exercise notes')
    end
  end

  describe 'through associations' do
    it 'can access core exercise attributes through association' do
      core_exercise = create(:core_exercise, name: 'Plank')
      training_exercise = create(:training_core_exercise, core_exercise: core_exercise)

      expect(training_exercise.core_exercise.name).to eq('Plank')
    end

    it 'can access training attributes through association' do
      training = create(:training, name: 'Core Workout')
      training_exercise = create(:training_core_exercise, training: training)

      expect(training_exercise.training.name).to eq('Core Workout')
    end
  end

  describe 'data integrity' do
    it 'allows multiple exercises for the same training' do
      training = create(:training)
      exercise1 = create(:training_core_exercise, training: training, position: 0)
      exercise2 = create(:training_core_exercise, training: training, position: 1)

      expect(training.training_core_exercises.count).to eq(2)
    end

    it 'can have different positions' do
      training = create(:training)
      exercise1 = create(:training_core_exercise, training: training, position: 0)
      exercise2 = create(:training_core_exercise, training: training, position: 1)
      exercise3 = create(:training_core_exercise, training: training, position: 2)

      positions = training.training_core_exercises.pluck(:position)
      expect(positions).to contain_exactly(0, 1, 2)
    end

    it 'can have varying reps and sets' do
      training = create(:training)
      low_reps = build(:training_core_exercise, training: training)
      low_reps.assign_attributes(sets: 2, reps: 10)
      low_reps.save!

      high_reps = build(:training_core_exercise, training: training)
      high_reps.assign_attributes(sets: 4, reps: 20)
      high_reps.save!

      expect(training.training_core_exercises.pluck(:reps).compact.map(&:to_i)).to contain_exactly(10, 20)
      expect(training.training_core_exercises.pluck(:sets)).to contain_exactly(2, 4)
    end
  end
end
