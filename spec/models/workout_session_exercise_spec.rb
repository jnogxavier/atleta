require 'rails_helper'

RSpec.describe WorkoutSessionExercise, type: :model do
  describe 'associations' do
    it { should belong_to(:workout_session) }
  end

  describe 'validations' do
    it { should validate_presence_of(:exercise_type) }
    it { should validate_presence_of(:exercise_id) }

    describe 'exercise_type inclusion' do
      it { should allow_value('strength').for(:exercise_type) }
      it { should allow_value('mobility').for(:exercise_type) }
      it { should allow_value('core').for(:exercise_type) }
      it { should allow_value('cardio').for(:exercise_type) }
      it { should_not allow_value('invalid').for(:exercise_type) }
      it { should_not allow_value('yoga').for(:exercise_type) }
    end
  end

  describe 'scopes' do
    let(:workout_session) { create(:workout_session) }
    let!(:completed_exercise) { create(:workout_session_exercise, workout_session: workout_session, completed: true) }
    let!(:pending_exercise) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }

    describe '.completed_exercises' do
      it 'returns only completed exercises' do
        expect(WorkoutSessionExercise.completed_exercises).to include(completed_exercise)
        expect(WorkoutSessionExercise.completed_exercises).not_to include(pending_exercise)
      end
    end

    describe '.pending_exercises' do
      it 'returns only pending exercises' do
        expect(WorkoutSessionExercise.pending_exercises).to include(pending_exercise)
        expect(WorkoutSessionExercise.pending_exercises).not_to include(completed_exercise)
      end
    end
  end

  describe 'instance methods' do
    describe '#training_exercise' do
      let(:workout_session) { create(:workout_session) }

      context 'with strength exercise' do
        let(:training_strength) { create(:training_strength_exercise) }
        let(:exercise) { create(:workout_session_exercise, :strength, workout_session: workout_session, exercise_id: training_strength.id) }

        it 'returns the training strength exercise' do
          expect(exercise.training_exercise).to eq(training_strength)
        end
      end

      context 'with mobility exercise' do
        let(:training_mobility) { create(:training_mobility_exercise) }
        let(:exercise) { create(:workout_session_exercise, :mobility, workout_session: workout_session, exercise_id: training_mobility.id) }

        it 'returns the training mobility exercise' do
          expect(exercise.training_exercise).to eq(training_mobility)
        end
      end

      context 'with core exercise' do
        let(:training_core) { create(:training_core_exercise) }
        let(:exercise) { create(:workout_session_exercise, :core, workout_session: workout_session, exercise_id: training_core.id) }

        it 'returns the training core exercise' do
          expect(exercise.training_exercise).to eq(training_core)
        end
      end

      context 'with cardio exercise' do
        let(:training_cardio) { create(:training_cardio_exercise) }
        let(:exercise) { create(:workout_session_exercise, :cardio, workout_session: workout_session, exercise_id: training_cardio.id) }

        it 'returns the training cardio exercise' do
          expect(exercise.training_exercise).to eq(training_cardio)
        end
      end
    end

    describe '#toggle_completion!' do
      let(:workout_session) { create(:workout_session) }
      let(:exercise) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }

      it 'toggles from incomplete to complete' do
        expect {
          exercise.toggle_completion!
        }.to change { exercise.reload.completed }.from(false).to(true)
      end

      it 'toggles from complete to incomplete' do
        exercise.update(completed: true)
        expect {
          exercise.toggle_completion!
        }.to change { exercise.reload.completed }.from(true).to(false)
      end

      it 'returns true on success' do
        expect(exercise.toggle_completion!).to be_truthy
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:workout_session_exercise)).to be_valid
    end

    describe 'traits' do
      it 'creates completed exercise' do
        exercise = create(:workout_session_exercise, :completed)
        expect(exercise.completed).to be true
      end

      it 'creates strength exercise' do
        exercise = create(:workout_session_exercise, :strength)
        expect(exercise.exercise_type).to eq('strength')
      end

      it 'creates cardio exercise' do
        exercise = create(:workout_session_exercise, :cardio)
        expect(exercise.exercise_type).to eq('cardio')
      end

      it 'creates core exercise' do
        exercise = create(:workout_session_exercise, :core)
        expect(exercise.exercise_type).to eq('core')
      end

      it 'creates mobility exercise' do
        exercise = create(:workout_session_exercise, :mobility)
        expect(exercise.exercise_type).to eq('mobility')
      end
    end
  end
end
