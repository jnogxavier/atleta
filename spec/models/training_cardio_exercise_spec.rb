require 'rails_helper'

RSpec.describe TrainingCardioExercise, type: :model do
  describe 'associations' do
    it { should belong_to(:training) }
    it { should belong_to(:cardio_exercise) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:duration).is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:calories).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0).allow_nil }

    it 'allows nil duration' do
      exercise = build(:training_cardio_exercise, duration: nil)
      expect(exercise).to be_valid
    end

    it 'rejects zero duration' do
      exercise = build(:training_cardio_exercise, duration: 0)
      expect(exercise).not_to be_valid
      expect(exercise.errors[:duration]).to be_present
    end

    it 'rejects negative duration' do
      exercise = build(:training_cardio_exercise, duration: -10)
      expect(exercise).not_to be_valid
      expect(exercise.errors[:duration]).to be_present
    end

    it 'allows zero calories' do
      exercise = build(:training_cardio_exercise, calories: 0)
      expect(exercise).to be_valid
    end

    it 'allows nil calories' do
      exercise = build(:training_cardio_exercise, calories: nil)
      expect(exercise).to be_valid
    end

    it 'rejects negative calories' do
      exercise = build(:training_cardio_exercise, calories: -100)
      expect(exercise).not_to be_valid
      expect(exercise.errors[:calories]).to be_present
    end
  end

  describe 'enums' do
    it { should define_enum_for(:intensity).with_values(low: 'low', moderate: 'moderate', high: 'high').backed_by_column_of_type(:string).with_prefix(:intensity) }

    it 'allows setting intensity to low' do
      exercise = create(:training_cardio_exercise, intensity: :low)
      expect(exercise.intensity_low?).to be true
    end

    it 'allows setting intensity to moderate' do
      exercise = create(:training_cardio_exercise, intensity: :moderate)
      expect(exercise.intensity_moderate?).to be true
    end

    it 'allows setting intensity to high' do
      exercise = create(:training_cardio_exercise, intensity: :high)
      expect(exercise.intensity_high?).to be true
    end
  end

  describe 'callbacks' do
    describe '#normalize_blank_values' do
      it 'converts blank duration to nil' do
        exercise = build(:training_cardio_exercise)
        exercise.duration = ''
        exercise.save
        expect(exercise.duration).to be_nil
      end

      it 'converts blank calories to nil' do
        exercise = build(:training_cardio_exercise)
        exercise.calories = ''
        exercise.save
        expect(exercise.calories).to be_nil
      end

      it 'converts blank notes to nil' do
        exercise = build(:training_cardio_exercise)
        exercise.notes = ''
        exercise.save
        expect(exercise.notes).to be_nil
      end

      it 'keeps valid duration value' do
        exercise = build(:training_cardio_exercise)
        exercise.duration = 30
        exercise.save
        expect(exercise.duration).to eq(30)
      end

      it 'keeps valid calories value' do
        exercise = build(:training_cardio_exercise)
        exercise.calories = 250
        exercise.save
        expect(exercise.calories).to eq(250)
      end
    end
  end

  describe '#total_calories' do
    it 'returns the calories value when set' do
      exercise = build(:training_cardio_exercise, calories: 300)
      expect(exercise.total_calories).to eq(300)
    end

    it 'returns 0 when calories is nil' do
      exercise = build(:training_cardio_exercise, calories: nil)
      expect(exercise.total_calories).to eq(0)
    end

    it 'returns 0 when calories is not set' do
      exercise = build(:training_cardio_exercise)
      exercise.calories = nil
      expect(exercise.total_calories).to eq(0)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      exercise = build(:training_cardio_exercise)
      expect(exercise).to be_valid
    end

    it 'creates a training cardio exercise with all attributes' do
      exercise = create(:training_cardio_exercise,
        duration: 30,
        intensity: :high,
        calories: 400,
        position: 1,
        notes: 'Test cardio notes')

      expect(exercise.duration).to eq(30)
      expect(exercise.intensity).to eq('high')
      expect(exercise.calories).to eq(400)
      expect(exercise.position).to eq(1)
      expect(exercise.notes).to eq('Test cardio notes')
    end
  end

  describe 'through associations' do
    it 'can access cardio exercise attributes through association' do
      cardio_exercise = create(:cardio_exercise, name: 'Running')
      training_exercise = create(:training_cardio_exercise, cardio_exercise: cardio_exercise)

      expect(training_exercise.cardio_exercise.name).to eq('Running')
    end

    it 'can access training attributes through association' do
      training = create(:training, name: 'Cardio Day')
      training_exercise = create(:training_cardio_exercise, training: training)

      expect(training_exercise.training.name).to eq('Cardio Day')
    end
  end

  describe 'data integrity' do
    it 'allows multiple cardio exercises for the same training' do
      training = create(:training)
      exercise1 = create(:training_cardio_exercise, training: training, position: 0)
      exercise2 = create(:training_cardio_exercise, training: training, position: 1)

      expect(training.training_cardio_exercises.count).to eq(2)
    end

    it 'can have different intensities in the same training' do
      training = create(:training)
      low_intensity = create(:training_cardio_exercise, training: training, intensity: :low)
      high_intensity = create(:training_cardio_exercise, training: training, intensity: :high)

      intensities = training.training_cardio_exercises.pluck(:intensity)
      expect(intensities).to contain_exactly('low', 'high')
    end
  end
end
