require 'rails_helper'

RSpec.describe Training, type: :model do
  describe 'associations' do
    it { should belong_to(:student_profile) }
    it { should have_many(:training_strength_exercises).dependent(:destroy) }
    it { should have_many(:strength_exercises).through(:training_strength_exercises) }
    it { should have_many(:training_mobility_exercises).dependent(:destroy) }
    it { should have_many(:mobility_exercises).through(:training_mobility_exercises) }
    it { should have_many(:training_core_exercises).dependent(:destroy) }
    it { should have_many(:core_exercises).through(:training_core_exercises) }
    it { should have_many(:training_cardio_exercises).dependent(:destroy) }
    it { should have_many(:cardio_exercises).through(:training_cardio_exercises) }
    it { should have_many(:workout_sessions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:day) }
  end

  describe 'scopes' do
    describe '.active_trainings' do
      it 'returns only active trainings' do
        active_training = create(:training, active: true)
        inactive_training = create(:training, active: false)

        expect(Training.active_trainings).to include(active_training)
        expect(Training.active_trainings).not_to include(inactive_training)
      end
    end
  end

  describe '#total_exercises' do
    it 'returns 0 when no exercises are present' do
      training = create(:training)
      expect(training.total_exercises).to eq(0)
    end

    it 'counts strength exercises' do
      training = create(:training, :with_strength_exercises)
      expect(training.total_exercises).to eq(3)
    end

    it 'counts all exercise types' do
      training = create(:training, :complete)
      expected_count = training.training_strength_exercises.size +
                      training.training_mobility_exercises.size +
                      training.training_core_exercises.size +
                      training.training_cardio_exercises.size

      expect(training.total_exercises).to eq(expected_count)
    end
  end

  describe 'exercises ordering' do
    it 'orders strength exercises by position' do
      training = create(:training)
      exercise1 = create(:training_strength_exercise, training: training, position: 2)
      exercise2 = create(:training_strength_exercise, training: training, position: 0)
      exercise3 = create(:training_strength_exercise, training: training, position: 1)

      expect(training.training_strength_exercises.to_a).to eq([ exercise2, exercise3, exercise1 ])
    end

    it 'orders mobility exercises by position' do
      training = create(:training)
      exercise1 = create(:training_mobility_exercise, training: training, position: 1)
      exercise2 = create(:training_mobility_exercise, training: training, position: 0)

      expect(training.training_mobility_exercises.to_a).to eq([ exercise2, exercise1 ])
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      training = build(:training)
      expect(training).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:training, :inactive)).to be_valid
      expect(build(:training, :with_strength_exercises)).to be_valid
      expect(build(:training, :with_mobility_exercises)).to be_valid
      expect(build(:training, :with_core_exercises)).to be_valid
      expect(build(:training, :with_cardio_exercises)).to be_valid
      expect(build(:training, :complete)).to be_valid
    end
  end
end
