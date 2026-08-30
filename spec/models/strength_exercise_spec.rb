require 'rails_helper'

RSpec.describe StrengthExercise, type: :model do
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

    describe 'specific to StrengthExercise' do
      it { should validate_length_of(:muscle_group).is_at_most(100) }
      it { should validate_length_of(:equipment).is_at_most(100) }
      it { should allow_value(nil).for(:muscle_group) }
      it { should allow_value('').for(:muscle_group) }
      it { should allow_value(nil).for(:equipment) }
      it { should allow_value('').for(:equipment) }
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:strength_exercise)).to be_valid
    end

    it 'creates a strength exercise with required attributes' do
      exercise = create(:strength_exercise)
      expect(exercise.name).to be_present
    end

    it 'creates a strength exercise with optional attributes' do
      exercise = create(:strength_exercise,
        muscle_group: 'Peitoral',
        equipment: 'Barra',
        description: 'Exercício de força para peito')
      expect(exercise.muscle_group).to eq('Peitoral')
      expect(exercise.equipment).to eq('Barra')
      expect(exercise.description).to eq('Exercício de força para peito')
    end
  end

  describe 'polymorphic videoable' do
    let(:exercise) { create(:strength_exercise) }

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
    it 'allows muscle_group to be set' do
      exercise = build(:strength_exercise, muscle_group: 'Costas')
      expect(exercise.muscle_group).to eq('Costas')
    end

    it 'allows equipment to be set' do
      exercise = build(:strength_exercise, equipment: 'Halteres')
      expect(exercise.equipment).to eq('Halteres')
    end
  end
end
