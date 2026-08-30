require 'rails_helper'

RSpec.describe CoreExercise, type: :model do
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
      expect(build(:core_exercise)).to be_valid
    end

    it 'creates a core exercise with required attributes' do
      exercise = create(:core_exercise)
      expect(exercise.name).to be_present
    end

    it 'creates a core exercise with description' do
      exercise = create(:core_exercise,
        description: 'Exercício para fortalecimento do core')
      expect(exercise.description).to eq('Exercício para fortalecimento do core')
    end
  end

  describe 'polymorphic videoable' do
    let(:exercise) { create(:core_exercise) }

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
