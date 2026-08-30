require 'rails_helper'

describe TrainingExerciseService do
  describe '#initialize' do
    it 'raises ArgumentError if training is not persisted' do
      training = Training.new
      expect {
        described_class.new(training)
      }.to raise_error(ArgumentError, "Training must be persisted")
    end

    it 'succeeds with a persisted training' do
      student = create(:student_profile)
      training = create(:training, student_profile: student)
      service = described_class.new(training)
      expect(service).to be_a(described_class)
    end
  end

  describe '#add_exercises' do
    let(:student) { create(:student_profile) }
    let(:training) { create(:training, student_profile: student) }
    let(:strength_exercise) { create(:strength_exercise) }
    let(:mobility_exercise) { create(:mobility_exercise) }
    let(:service) { described_class.new(training) }

    let(:exercises_params) do
      {
        "strength" => {
          strength_exercise.id.to_s => { "sets" => 3, "reps" => 10, "rest" => 60, "order" => 1, "notes" => "Test" }
        },
        "mobility" => {
          mobility_exercise.id.to_s => { "sets" => 2, "duration" => 30, "order" => 2, "notes" => "Warmup" }
        }
      }
    end

    it 'adds strength exercises to training' do
      expect {
        service.add_exercises(exercises_params)
      }.to change { training.training_strength_exercises.count }.by(1)
    end

    it 'adds mobility exercises to training' do
      expect {
        service.add_exercises(exercises_params)
      }.to change { training.training_mobility_exercises.count }.by(1)
    end

    it 'stores exercise details correctly' do
      service.add_exercises(exercises_params)
      exercise = training.training_strength_exercises.first
      expect(exercise.strength_exercise_id).to eq(strength_exercise.id)
      expect(exercise.notes).to eq("Test")
      expect(exercise).to be_persisted
    end

    it 'raises error if exercise does not exist' do
      invalid_params = {
        "strength" => {
          "999999" => { "sets" => 3, "reps" => 10, "rest" => 60, "order" => 1 }
        }
      }
      expect {
        service.add_exercises(invalid_params)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'with transaction' do
      it 'rolls back all changes if one exercise fails' do
        invalid_params = {
          "strength" => {
            strength_exercise.id.to_s => { "sets" => 3, "reps" => 10, "rest" => 60, "order" => 1 },
            "999999" => { "sets" => 3, "reps" => 10, "rest" => 60, "order" => 2 }
          }
        }

        expect {
          service.add_exercises(invalid_params)
        }.to raise_error(ActiveRecord::RecordNotFound)

        expect(training.training_strength_exercises.count).to eq(0)
      end
    end
  end

  describe '#update_exercises' do
    let(:student) { create(:student_profile) }
    let(:training) { create(:training, student_profile: student) }
    let(:strength_exercise) { create(:strength_exercise) }
    let(:service) { described_class.new(training) }

    context 'with existing exercises' do
      before do
        create(:training_strength_exercise, training: training, strength_exercise: strength_exercise, sets: 2)
      end

      it 'clears all existing exercises' do
        new_params = {
          "strength" => {}
        }
        service.update_exercises(new_params)
        expect(training.training_strength_exercises.count).to eq(0)
      end

      it 'adds new exercises after clearing' do
        another_exercise = create(:strength_exercise)
        new_params = {
          "strength" => {
            another_exercise.id.to_s => { "sets" => 4, "reps" => 8, "rest" => 90, "order" => 1 }
          }
        }
        service.update_exercises(new_params)
        expect(training.training_strength_exercises.count).to eq(1)
        expect(training.training_strength_exercises.first.strength_exercise_id).to eq(another_exercise.id)
        expect(training.training_strength_exercises.first.sets).to eq(4)
      end
    end

    context 'transaction atomicity' do
      before do
        create(:training_strength_exercise, training: training, strength_exercise: strength_exercise, sets: 2)
      end

      it 'rolls back everything if update fails partway' do
        invalid_params = {
          "strength" => {
            strength_exercise.id.to_s => { "sets" => 5, "reps" => 12, "rest" => 75, "order" => 1 },
            "999999" => { "sets" => 3, "reps" => 10, "rest" => 60, "order" => 2 }
          }
        }

        expect {
          service.update_exercises(invalid_params)
        }.to raise_error(ActiveRecord::RecordNotFound)

        # Original exercise should still exist unchanged due to transaction rollback
        expect(training.training_strength_exercises.count).to eq(1)
        original_exercise = training.training_strength_exercises.first
        expect(original_exercise.strength_exercise_id).to eq(strength_exercise.id)
      end
    end
  end

  describe '#clear_all_exercises' do
    let(:student) { create(:student_profile) }
    let(:training) { create(:training, student_profile: student) }
    let(:service) { described_class.new(training) }

    before do
      create(:training_strength_exercise, training: training)
      create(:training_mobility_exercise, training: training)
      create(:training_core_exercise, training: training)
      create(:training_cardio_exercise, training: training)
    end

    it 'clears all exercise types' do
      service.send(:clear_all_exercises)

      expect(training.training_strength_exercises.count).to eq(0)
      expect(training.training_mobility_exercises.count).to eq(0)
      expect(training.training_core_exercises.count).to eq(0)
      expect(training.training_cardio_exercises.count).to eq(0)
    end
  end
end
