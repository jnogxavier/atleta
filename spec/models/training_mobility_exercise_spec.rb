require 'rails_helper'

RSpec.describe TrainingMobilityExercise, type: :model do
  describe 'associations' do
    it { should belong_to(:training) }
    it { should belong_to(:mobility_exercise) }
  end

  describe 'validations' do
    describe 'from TrainingExerciseValidations concern' do
      it { should validate_numericality_of(:sets).only_integer.is_greater_than(0).allow_nil }
      it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    end

    describe 'specific to TrainingMobilityExercise' do
      it { should validate_numericality_of(:duration).only_integer.is_greater_than(0).allow_nil }

      it 'allows nil duration' do
        exercise = build(:training_mobility_exercise, duration: nil)
        expect(exercise).to be_valid
      end

      it 'rejects zero duration' do
        exercise = build(:training_mobility_exercise, duration: 0)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:duration]).to be_present
      end

      it 'rejects negative duration' do
        exercise = build(:training_mobility_exercise, duration: -5)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:duration]).to be_present
      end

      it 'rejects non-integer duration' do
        exercise = build(:training_mobility_exercise, duration: 30.5)
        expect(exercise).not_to be_valid
        expect(exercise.errors[:duration]).to be_present
      end
    end
  end

  describe 'callbacks' do
    describe '#normalize_duration' do
      it 'converts blank duration to nil' do
        exercise = build(:training_mobility_exercise)
        exercise.duration = ''
        exercise.save
        expect(exercise.duration).to be_nil
      end

      it 'keeps valid duration value' do
        exercise = build(:training_mobility_exercise)
        exercise.duration = 45
        exercise.save
        expect(exercise.duration.to_i).to eq(45)
      end

      it 'handles string duration values' do
        exercise = build(:training_mobility_exercise)
        exercise.duration = '30'
        exercise.save
        expect(exercise.duration).to eq('30')
      end
    end

    describe '#normalize_blank_values from concern' do
      it 'converts blank sets to nil' do
        exercise = build(:training_mobility_exercise)
        exercise.sets = ''
        exercise.save
        expect(exercise.sets).to be_nil
      end

      it 'converts blank notes to nil' do
        exercise = build(:training_mobility_exercise)
        exercise.notes = ''
        exercise.save
        expect(exercise.notes).to be_nil
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      exercise = build(:training_mobility_exercise)
      expect(exercise).to be_valid
    end

    it 'creates a training mobility exercise with all attributes' do
      exercise = build(:training_mobility_exercise)
      exercise.assign_attributes(
        sets: 2,
        duration: 60,
        hold: 20,
        position: 3,
        notes: 'Mobility exercise notes')
      exercise.save!

      expect(exercise.sets).to eq(2)
      expect(exercise.duration.to_i).to eq(60)
      expect(exercise.hold.to_i).to eq(20)
      expect(exercise.position).to eq(3)
      expect(exercise.notes).to eq('Mobility exercise notes')
    end
  end

  describe 'through associations' do
    it 'can access mobility exercise attributes through association' do
      mobility_exercise = create(:mobility_exercise, name: 'Hip Flexor Stretch')
      training_exercise = create(:training_mobility_exercise, mobility_exercise: mobility_exercise)

      expect(training_exercise.mobility_exercise.name).to eq('Hip Flexor Stretch')
    end

    it 'can access training attributes through association' do
      training = create(:training, name: 'Mobility Day')
      training_exercise = create(:training_mobility_exercise, training: training)

      expect(training_exercise.training.name).to eq('Mobility Day')
    end
  end

  describe 'data integrity' do
    it 'allows multiple exercises for the same training' do
      training = create(:training)
      exercise1 = create(:training_mobility_exercise, training: training, position: 0)
      exercise2 = create(:training_mobility_exercise, training: training, position: 1)

      expect(training.training_mobility_exercises.count).to eq(2)
    end

    it 'can have different positions' do
      training = create(:training)
      exercise1 = create(:training_mobility_exercise, training: training, position: 0)
      exercise2 = create(:training_mobility_exercise, training: training, position: 1)
      exercise3 = create(:training_mobility_exercise, training: training, position: 2)

      positions = training.training_mobility_exercises.pluck(:position)
      expect(positions).to contain_exactly(0, 1, 2)
    end

    it 'can have varying durations and holds' do
      training = create(:training)
      short_hold = build(:training_mobility_exercise, training: training)
      short_hold.assign_attributes(duration: 30, hold: 10)
      short_hold.save!

      long_hold = build(:training_mobility_exercise, training: training)
      long_hold.assign_attributes(duration: 60, hold: 30)
      long_hold.save!

      durations = training.training_mobility_exercises.pluck(:duration).compact.map(&:to_i)
      expect(durations).to contain_exactly(30, 60)
    end
  end

  describe 'hold attribute' do
    it 'allows setting hold time' do
      exercise = build(:training_mobility_exercise)
      exercise.hold = 25
      exercise.save!
      expect(exercise.hold.to_i).to eq(25)
    end

    it 'allows nil hold time' do
      exercise = build(:training_mobility_exercise)
      exercise.hold = nil
      exercise.save!
      expect(exercise).to be_valid
      expect(exercise.hold).to be_nil
    end

    it 'allows string hold time from factory' do
      exercise = build(:training_mobility_exercise)
      exercise.hold = '15'
      exercise.save!
      expect(exercise.hold).to eq('15')
    end
  end
end
