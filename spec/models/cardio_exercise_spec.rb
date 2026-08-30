require 'rails_helper'

RSpec.describe CardioExercise, type: :model do
  describe 'associations' do
    it { should have_many(:videos).dependent(:destroy) }
  end

  describe 'validations' do
    describe 'from Exercisable concern' do
      it { should validate_presence_of(:name) }
      it { should validate_length_of(:description).is_at_most(1000) }
      it { should allow_value(nil).for(:description) }
      it { should allow_value('').for(:description) }
    end

    describe 'specific to CardioExercise' do
      it { should validate_length_of(:cardio_type).is_at_most(100) }
      it { should allow_value(nil).for(:cardio_type) }
      it { should allow_value('').for(:cardio_type) }
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cardio_exercise)).to be_valid
    end

    it 'creates a cardio exercise with required attributes' do
      exercise = create(:cardio_exercise)
      expect(exercise.name).to be_present
    end

    it 'creates a cardio exercise with optional attributes' do
      exercise = create(:cardio_exercise,
        cardio_type: 'HIIT',
        description: 'Exercício cardiovascular de alta intensidade')
      expect(exercise.cardio_type).to eq('HIIT')
      expect(exercise.description).to eq('Exercício cardiovascular de alta intensidade')
    end
  end

  describe 'polymorphic videoable' do
    let(:exercise) { create(:cardio_exercise) }

    it 'can have videos associated' do
      video = create(:video, videoable: exercise)
      expect(exercise.videos).to include(video)
    end

    it 'destroys associated videos when destroyed' do
      video = create(:video, videoable: exercise)
      expect { exercise.destroy }.to change { Video.count }.by(-1)
    end
  end

  describe 'attributes' do
    it 'allows cardio_type to be set' do
      exercise = build(:cardio_exercise, cardio_type: 'Corrida')
      expect(exercise.cardio_type).to eq('Corrida')
    end
  end
end
