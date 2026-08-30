require 'rails_helper'

describe WorkoutSessionService do
  describe '.initialize_workout_session' do
    let(:student_profile) { create(:student_profile) }
    let(:training) { create(:training, :complete, student_profile: student_profile) }

    it 'creates a new workout session' do
      expect {
        described_class.initialize_workout_session(student_profile, training)
      }.to change { student_profile.workout_sessions.count }.by(1)
    end

    it 'returns the created session' do
      session = described_class.initialize_workout_session(student_profile, training)
      expect(session).to be_a(WorkoutSession)
      expect(session.training).to eq(training)
    end

    it 'creates workout session exercises for all training exercises' do
      session = described_class.initialize_workout_session(student_profile, training)
      expect(session.workout_session_exercises.count).to be > 0
    end

    it 'creates exercises for strength training' do
      session = described_class.initialize_workout_session(student_profile, training)
      strength_count = training.training_strength_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'strength').count).to eq(strength_count)
    end

    it 'creates exercises for mobility training' do
      session = described_class.initialize_workout_session(student_profile, training)
      mobility_count = training.training_mobility_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'mobility').count).to eq(mobility_count)
    end

    it 'creates exercises for core training' do
      session = described_class.initialize_workout_session(student_profile, training)
      core_count = training.training_core_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'core').count).to eq(core_count)
    end

    it 'creates exercises for cardio training' do
      session = described_class.initialize_workout_session(student_profile, training)
      cardio_count = training.training_cardio_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'cardio').count).to eq(cardio_count)
    end

    it 'wraps creation in a transaction' do
      allow(training.training_strength_exercises).to receive(:each).and_raise(StandardError)

      expect {
        described_class.initialize_workout_session(student_profile, training) rescue nil
      }.not_to change { student_profile.workout_sessions.count }
    end

    it 'raises WorkoutSessionInitializationError on failure' do
      allow(student_profile.workout_sessions).to receive(:create!).and_raise(StandardError, 'Database error')

      expect {
        described_class.initialize_workout_session(student_profile, training)
      }.to raise_error(WorkoutSessionInitializationError)
    end
  end

  describe '.complete_workout_session' do
    let(:student_profile) { create(:student_profile) }
    let(:training) { create(:training, :complete, student_profile: student_profile) }
    let(:session) { create(:workout_session, student_profile: student_profile, training: training) }

    it 'marks the session as completed' do
      expect(session.completed_at).to be_nil
      described_class.complete_workout_session(session)
      expect(session.reload.completed_at).to be_present
    end

    it 'returns true on success' do
      result = described_class.complete_workout_session(session)
      expect(result).to be(true)
    end

    it 'returns false when session is nil' do
      result = described_class.complete_workout_session(nil)
      expect(result).to be(false)
    end

    it 'raises WorkoutSessionCompletionError on failure' do
      allow(session).to receive(:update!).and_raise(StandardError, 'Database error')

      expect {
        described_class.complete_workout_session(session)
      }.to raise_error(WorkoutSessionCompletionError)
    end
  end
end
