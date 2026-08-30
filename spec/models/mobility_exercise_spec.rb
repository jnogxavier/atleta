require 'rails_helper'

RSpec.describe MobilityExercise, type: :model do
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
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:mobility_exercise)).to be_valid
    end

    it 'creates a mobility exercise with required attributes' do
      exercise = create(:mobility_exercise)
      expect(exercise.name).to be_present
    end

    it 'creates a mobility exercise with description' do
      exercise = create(:mobility_exercise,
        description: 'Exercício para melhoria da mobilidade')
      expect(exercise.description).to eq('Exercício para melhoria da mobilidade')
    end
  end

  describe 'polymorphic videoable' do
    let(:exercise) { create(:mobility_exercise) }

    it 'can have videos associated' do
      video = create(:video, videoable: exercise)
      expect(exercise.videos).to include(video)
    end

    it 'destroys associated videos when destroyed' do
      video = create(:video, videoable: exercise)
      expect { exercise.destroy }.to change { Video.count }.by(-1)
    end
  end
end
