require 'rails_helper'

RSpec.describe TrainingStrengthExercise, type: :model do
  describe 'associations' do
    it { should belong_to(:training) }
    it { should belong_to(:strength_exercise) }
  end

  describe 'validations' do
    describe 'from TrainingExerciseValidations concern' do
      it { should validate_numericality_of(:sets).only_integer.is_greater_than(0).allow_nil }
      it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0).allow_nil }
      it { should validate_numericality_of(:rest).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    end

    describe 'specific to TrainingStrengthExercise' do
      it { should validate_numericality_of(:reps).only_integer.is_greater_than(0).allow_nil }

      it 'allows nil reps' do
        exercise = build(:training_strength_exercise, reps: nil)
        expect(exercise).to be_valid
      end

      it 'rejects zero reps' do
        exercise = build(:training_strength_exercise, reps: 0)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:reps]).to be_present
      end

      it 'rejects negative reps' do
        exercise = build(:training_strength_exercise, reps: -5)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:reps]).to be_present
      end

      it 'rejects non-integer reps' do
        exercise = build(:training_strength_exercise, reps: 10.5)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:reps]).to be_present
      end
    end
  end

  describe 'callbacks' do
    describe '#normalize_reps' do
      it 'converts blank reps to nil' do
        exercise = build(:training_strength_exercise)
        exercise.reps = ''
        exercise.save
        expect(exercise.reps).to be_nil
      end

      it 'keeps valid reps value' do
        exercise = build(:training_strength_exercise)
        exercise.reps = 10
        exercise.save
        expect(exercise.reps.to_i).to eq(10)
      end
    end

    describe '#normalize_blank_values from concern' do
      it 'converts blank sets to nil' do
        exercise = build(:training_strength_exercise)
        exercise.sets = ''
        exercise.save
        expect(exercise.sets).to be_nil
      end

      it 'converts blank rest to nil' do
        exercise = build(:training_strength_exercise)
        exercise.rest = ''
        exercise.save
        expect(exercise.rest).to be_nil
      end

      it 'converts blank notes to nil' do
        exercise = build(:training_strength_exercise)
        exercise.notes = ''
        exercise.save
        expect(exercise.notes).to be_nil
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      exercise = build(:training_strength_exercise)
      expect(exercise).to be_valid
    end

    it 'creates a training strength exercise with all attributes' do
      exercise = build(:training_strength_exercise)
      exercise.assign_attributes(
        sets: 3,
        reps: 12,
        rest: 60,
        position: 1,
        notes: 'Test notes')
      exercise.save!

      expect(exercise.sets).to eq(3)
      expect(exercise.reps.to_i).to eq(12)
      expect(exercise.rest.to_i).to eq(60)
      expect(exercise.position).to eq(1)
      expect(exercise.notes).to eq('Test notes')
    end
  end

  describe 'through associations' do
    it 'can access strength exercise attributes through association' do
      strength_exercise = create(:strength_exercise, name: 'Bench Press')
      training_exercise = create(:training_strength_exercise, strength_exercise: strength_exercise)

      expect(training_exercise.strength_exercise.name).to eq('Bench Press')
    end

    it 'can access training attributes through association' do
      training = create(:training, name: 'Monday Workout')
      training_exercise = create(:training_strength_exercise, training: training)

      expect(training_exercise.training.name).to eq('Monday Workout')
    end
  end

  describe 'data integrity' do
    it 'allows multiple exercises for the same training' do
      training = create(:training)
      exercise1 = create(:training_strength_exercise, training: training, position: 0)
      exercise2 = create(:training_strength_exercise, training: training, position: 1)

      expect(training.training_strength_exercises.count).to eq(2)
    end

    it 'can have different positions' do
      training = create(:training)
      exercise1 = create(:training_strength_exercise, training: training, position: 0)
      exercise2 = create(:training_strength_exercise, training: training, position: 1)
      exercise3 = create(:training_strength_exercise, training: training, position: 2)

      positions = training.training_strength_exercises.pluck(:position)
      expect(positions).to contain_exactly(0, 1, 2)
    end
  end
end
