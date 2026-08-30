require 'rails_helper'

RSpec.describe StudentProfile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:trainings).dependent(:destroy) }
    it { should have_many(:workout_sessions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:student_profile) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:student_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 'active', inactive: 'inactive', suspended: 'suspended').backed_by_column_of_type(:string).with_default(:active) }
  end

  describe 'callbacks' do
    describe '#generate_student_id' do
      it 'generates a unique student_id before creation' do
        profile = create(:student_profile)
        expect(profile.student_id).to be_present
        expect(profile.student_id.length).to eq(8)
      end

      it 'ensures student_id is unique' do
        profile1 = create(:student_profile)
        profile2 = create(:student_profile)
        expect(profile1.student_id).not_to eq(profile2.student_id)
      end
    end

    describe '#sync_name_from_user' do
      it 'syncs name from user if user has a name' do
        user = create(:user, name: 'John Doe')
        profile = create(:student_profile, user: user, name: 'Old Name')
        expect(profile.name).to eq('John Doe')
      end

      it 'does not override name if user name is blank' do
        user = create(:user, name: nil)
        profile = create(:student_profile, user: user, name: 'Profile Name')
        expect(profile.name).to eq('Profile Name')
      end
    end
  end

  describe '#currently_active?' do
    it 'returns true for active status with no expiration' do
      profile = create(:student_profile, status: :active, expires_at: nil)
      expect(profile.currently_active?).to be true
    end

    it 'returns true for active status with future expiration' do
      profile = create(:student_profile, status: :active, expires_at: 30.days.from_now)
      expect(profile.currently_active?).to be true
    end

    it 'returns false for active status with past expiration' do
      profile = create(:student_profile, status: :active, expires_at: 1.day.ago)
      expect(profile.currently_active?).to be false
    end

    it 'returns false for inactive status' do
      profile = create(:student_profile, status: :inactive, expires_at: nil)
      expect(profile.currently_active?).to be false
    end
  end

  describe '#expired?' do
    it 'returns true when expires_at is in the past' do
      profile = create(:student_profile, expires_at: 1.day.ago)
      expect(profile.expired?).to be true
    end

    it 'returns false when expires_at is in the future' do
      profile = create(:student_profile, expires_at: 30.days.from_now)
      expect(profile.expired?).to be false
    end

    it 'returns false when expires_at is nil' do
      profile = create(:student_profile, expires_at: nil)
      expect(profile.expired?).to be false
    end
  end

  describe '#active_trainings' do
    it 'returns only active trainings' do
      profile = create(:student_profile)
      active_training = create(:training, student_profile: profile, active: true)
      inactive_training = create(:training, student_profile: profile, active: false)

      expect(profile.active_trainings).to include(active_training)
      expect(profile.active_trainings).not_to include(inactive_training)
    end
  end

  describe '#current_workout_session' do
    it 'returns in-progress workout session for the given training' do
      profile = create(:student_profile)
      training = create(:training, student_profile: profile)
      session = create(:workout_session, student_profile: profile, training: training, completed_at: nil)

      expect(profile.current_workout_session(training)).to eq(session)
    end

    it 'returns nil if no in-progress session exists' do
      profile = create(:student_profile)
      training = create(:training, student_profile: profile)

      expect(profile.current_workout_session(training)).to be_nil
    end
  end

  describe '#start_workout_session' do
    let(:profile) { create(:student_profile) }
    let(:training) { create(:training, :complete, student_profile: profile) }

    it 'creates a new workout session' do
      expect {
        profile.start_workout_session(training)
      }.to change { profile.workout_sessions.count }.by(1)
    end

    it 'creates workout session exercises for all training exercises' do
      session = profile.start_workout_session(training)

      expect(session.workout_session_exercises.count).to be > 0
    end

    it 'creates exercises for strength training' do
      session = profile.start_workout_session(training)
      strength_count = training.training_strength_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'strength').count).to eq(strength_count)
    end

    it 'creates exercises for mobility training' do
      session = profile.start_workout_session(training)
      mobility_count = training.training_mobility_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'mobility').count).to eq(mobility_count)
    end

    it 'creates exercises for core training' do
      session = profile.start_workout_session(training)
      core_count = training.training_core_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'core').count).to eq(core_count)
    end

    it 'creates exercises for cardio training' do
      session = profile.start_workout_session(training)
      cardio_count = training.training_cardio_exercises.count

      expect(session.workout_session_exercises.where(exercise_type: 'cardio').count).to eq(cardio_count)
    end

    it 'wraps creation in a transaction' do
      allow(training.training_strength_exercises).to receive(:each).and_raise(StandardError)

      expect {
        profile.start_workout_session(training) rescue nil
      }.not_to change { profile.workout_sessions.count }
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      profile = build(:student_profile)
      expect(profile).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:student_profile, :inactive)).to be_valid
      expect(build(:student_profile, :suspended)).to be_valid
      expect(build(:student_profile, :expired)).to be_valid
      expect(build(:student_profile, :active_with_expiration)).to be_valid
    end
  end
end
