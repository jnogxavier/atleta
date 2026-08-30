require 'rails_helper'

RSpec.describe WorkoutSession, type: :model do
  describe 'associations' do
    it { should belong_to(:student_profile) }
    it { should belong_to(:training) }
    it { should have_many(:workout_session_exercises).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:training) }
    it { should validate_presence_of(:student_profile) }
  end

  describe 'scopes' do
    let(:student) { create(:user, :complete_student) }
    let(:training) { create(:training, student_profile: student.student_profile) }
    let!(:completed_session) { create(:workout_session, :completed, training: training, student_profile: student.student_profile) }
    let!(:in_progress_session) { create(:workout_session, :in_progress, training: training, student_profile: student.student_profile) }

    describe '.completed' do
      it 'returns only completed sessions' do
        expect(WorkoutSession.completed).to include(completed_session)
        expect(WorkoutSession.completed).not_to include(in_progress_session)
      end
    end

    describe '.in_progress' do
      it 'returns only in-progress sessions' do
        expect(WorkoutSession.in_progress).to include(in_progress_session)
        expect(WorkoutSession.in_progress).not_to include(completed_session)
      end
    end

    describe '.recent' do
      let!(:old_session) { create(:workout_session, training: training, student_profile: student.student_profile, created_at: 2.days.ago) }
      let!(:new_session) { create(:workout_session, training: training, student_profile: student.student_profile, created_at: 1.hour.ago) }

      it 'orders sessions by created_at descending' do
        recent = WorkoutSession.recent.where(id: [ old_session.id, new_session.id ])
        expect(recent.first).to eq(new_session)
        expect(recent.last).to eq(old_session)
      end
    end
  end

  describe 'instance methods' do
    let(:student) { create(:user, :complete_student) }
    let(:training) { create(:training, student_profile: student.student_profile) }
    let(:workout_session) { create(:workout_session, training: training, student_profile: student.student_profile) }

    describe '#completed?' do
      context 'when completed_at is present' do
        before { workout_session.update(completed_at: Time.current) }

        it 'returns true' do
          expect(workout_session.completed?).to be true
        end
      end

      context 'when completed_at is nil' do
        before { workout_session.update(completed_at: nil) }

        it 'returns false' do
          expect(workout_session.completed?).to be false
        end
      end
    end

    describe '#complete!' do
      it 'sets completed_at to current time' do
        workout_session.complete!
        expect(workout_session.reload.completed_at).to be_within(1.second).of(Time.current)
      end

      it 'returns true on success' do
        expect(workout_session.complete!).to be_truthy
      end
    end

    describe '#progress_percentage' do
      context 'when no exercises exist' do
        it 'returns 0' do
          expect(workout_session.progress_percentage).to eq(0)
        end
      end

      context 'when exercises exist' do
        let!(:completed_exercise1) { create(:workout_session_exercise, workout_session: workout_session, completed: true) }
        let!(:completed_exercise2) { create(:workout_session_exercise, workout_session: workout_session, completed: true) }
        let!(:pending_exercise1) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }
        let!(:pending_exercise2) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }

        it 'calculates correct percentage' do
          # 2 out of 4 = 50%
          expect(workout_session.progress_percentage).to eq(50)
        end
      end

      context 'when all exercises are completed' do
        let!(:completed_exercise1) { create(:workout_session_exercise, workout_session: workout_session, completed: true) }
        let!(:completed_exercise2) { create(:workout_session_exercise, workout_session: workout_session, completed: true) }

        it 'returns 100' do
          expect(workout_session.progress_percentage).to eq(100)
        end
      end

      context 'when no exercises are completed' do
        let!(:pending_exercise1) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }
        let!(:pending_exercise2) { create(:workout_session_exercise, workout_session: workout_session, completed: false) }

        it 'returns 0' do
          expect(workout_session.progress_percentage).to eq(0)
        end
      end
    end

    describe '#in_progress?' do
      context 'when not completed' do
        before { workout_session.update(completed_at: nil) }

        it 'returns true' do
          expect(workout_session.in_progress?).to be true
        end
      end

      context 'when completed' do
        before { workout_session.update(completed_at: Time.current) }

        it 'returns false' do
          expect(workout_session.in_progress?).to be false
        end
      end
    end

    describe '#add_cycle' do
      it 'adds a cycle with duration' do
        expect {
          workout_session.add_cycle(120)
        }.to change { workout_session.cycles.size }.by(1)
      end

      it 'stores the duration in the cycle' do
        workout_session.add_cycle(120)
        expect(workout_session.cycles.last['duration']).to eq(120)
      end

      it 'stores the started_at timestamp' do
        freeze_time do
          workout_session.add_cycle(120)
          expect(workout_session.cycles.last['started_at']).to eq(Time.current.iso8601)
        end
      end

      it 'persists the cycle to the database' do
        workout_session.add_cycle(120)
        workout_session.reload
        expect(workout_session.cycles.size).to eq(1)
        expect(workout_session.cycles.last['duration']).to eq(120)
      end

      it 'adds multiple cycles' do
        workout_session.add_cycle(120)
        workout_session.add_cycle(90)
        workout_session.add_cycle(110)

        expect(workout_session.cycles.size).to eq(3)
        expect(workout_session.cycles.map { |c| c['duration'] }).to eq([ 120, 90, 110 ])
      end

      it 'initializes cycles array if nil' do
        workout_session.update_column(:cycles, nil)
        workout_session.add_cycle(120)
        expect(workout_session.cycles).to be_an(Array)
        expect(workout_session.cycles.size).to eq(1)
      end
    end

    describe '#cycles_count' do
      it 'returns 0 when no cycles exist' do
        workout_session.update(cycles: [])
        expect(workout_session.cycles_count).to eq(0)
      end

      it 'returns correct count with one cycle' do
        workout_session.add_cycle(120)
        expect(workout_session.cycles_count).to eq(1)
      end

      it 'returns correct count with multiple cycles' do
        workout_session.add_cycle(120)
        workout_session.add_cycle(90)
        workout_session.add_cycle(110)
        expect(workout_session.cycles_count).to eq(3)
      end

      it 'returns 0 when cycles is nil' do
        workout_session.update_column(:cycles, nil)
        expect(workout_session.cycles_count).to eq(0)
      end
    end

    describe '#total_duration' do
      it 'returns 0 when no cycles exist' do
        workout_session.update(cycles: [])
        expect(workout_session.total_duration).to eq(0)
      end

      it 'returns correct total with one cycle' do
        workout_session.add_cycle(120)
        expect(workout_session.total_duration).to eq(120)
      end

      it 'sums all cycle durations' do
        workout_session.add_cycle(120)
        workout_session.add_cycle(90)
        workout_session.add_cycle(110)
        expect(workout_session.total_duration).to eq(320)
      end

      it 'returns 0 when cycles is nil' do
        workout_session.update_column(:cycles, nil)
        expect(workout_session.total_duration).to eq(0)
      end

      it 'handles cycles with missing duration' do
        workout_session.cycles = [
          { 'started_at' => Time.current.iso8601, 'duration' => 120 },
          { 'started_at' => Time.current.iso8601 }
        ]
        workout_session.save
        expect(workout_session.total_duration).to eq(120)
      end
    end

    describe '#current_cycle_start' do
      it 'returns nil when no cycles exist' do
        workout_session.update(cycles: [])
        expect(workout_session.current_cycle_start).to be_nil
      end

      it 'returns the started_at of the last cycle' do
        freeze_time do
          workout_session.add_cycle(120)
          travel 1.minute
          expected_start = Time.current
          workout_session.add_cycle(90)

          expect(workout_session.current_cycle_start).to be_within(1.second).of(expected_start)
        end
      end

      it 'returns nil when cycles is blank' do
        workout_session.update_column(:cycles, nil)
        expect(workout_session.current_cycle_start).to be_nil
      end
    end
  end

  describe 'difficulty enum' do
    let(:student) { create(:user, :complete_student) }
    let(:training) { create(:training, student_profile: student.student_profile) }
    let(:workout_session) { create(:workout_session, training: training, student_profile: student.student_profile) }

    it 'defines difficulty levels' do
      expect(WorkoutSession.difficulties).to eq({
        'facil' => 1,
        'medio' => 2,
        'dificil' => 3,
        'muito_dificil' => 4
      })
    end

    it 'allows setting difficulty as facil' do
      workout_session.update(difficulty: :facil)
      expect(workout_session.difficulty).to eq('facil')
      expect(workout_session.difficulty_facil?).to be true
    end

    it 'allows setting difficulty as medio' do
      workout_session.update(difficulty: :medio)
      expect(workout_session.difficulty).to eq('medio')
      expect(workout_session.difficulty_medio?).to be true
    end

    it 'allows setting difficulty as dificil' do
      workout_session.update(difficulty: :dificil)
      expect(workout_session.difficulty).to eq('dificil')
      expect(workout_session.difficulty_dificil?).to be true
    end

    it 'allows setting difficulty as muito_dificil' do
      workout_session.update(difficulty: :muito_dificil)
      expect(workout_session.difficulty).to eq('muito_dificil')
      expect(workout_session.difficulty_muito_dificil?).to be true
    end

    it 'allows setting difficulty by integer value' do
      workout_session.update(difficulty: 1)
      expect(workout_session.difficulty).to eq('facil')
    end

    it 'allows nil difficulty' do
      workout_session.update(difficulty: nil)
      expect(workout_session.difficulty).to be_nil
    end
  end

  describe 'weight_used' do
    let(:student) { create(:user, :complete_student) }
    let(:training) { create(:training, student_profile: student.student_profile) }
    let(:workout_session) { create(:workout_session, training: training, student_profile: student.student_profile) }

    it 'accepts decimal weight values' do
      workout_session.update(weight_used: 10.5)
      expect(workout_session.weight_used).to eq(10.5)
    end

    it 'accepts integer weight values' do
      workout_session.update(weight_used: 10)
      expect(workout_session.weight_used).to eq(10.0)
    end

    it 'allows nil weight' do
      workout_session.update(weight_used: nil)
      expect(workout_session.weight_used).to be_nil
    end
  end

  describe 'session_notes' do
    let(:student) { create(:user, :complete_student) }
    let(:training) { create(:training, student_profile: student.student_profile) }
    let(:workout_session) { create(:workout_session, training: training, student_profile: student.student_profile) }

    it 'accepts text notes' do
      notes = 'Treino muito bom, consegui completar todos os ciclos'
      workout_session.update(session_notes: notes)
      expect(workout_session.session_notes).to eq(notes)
    end

    it 'allows nil notes' do
      workout_session.update(session_notes: nil)
      expect(workout_session.session_notes).to be_nil
    end

    it 'accepts long text' do
      long_notes = 'a' * 1000
      workout_session.update(session_notes: long_notes)
      expect(workout_session.session_notes).to eq(long_notes)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:workout_session)).to be_valid
    end

    describe 'traits' do
      it 'creates completed workout session' do
        session = create(:workout_session, :completed)
        expect(session.completed?).to be true
      end

      it 'creates in-progress workout session' do
        session = create(:workout_session, :in_progress)
        expect(session.in_progress?).to be true
      end
    end
  end
end
