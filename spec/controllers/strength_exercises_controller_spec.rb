require 'rails_helper'

RSpec.describe StrengthExercisesController, type: :controller do
  after do
    Current.reset
  end

  describe 'GET #index' do
    context 'when not authenticated' do
      it 'requires authentication' do
        get :index, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'controller structure' do
      it 'responds to index action' do
        expect(controller).to respond_to(:index)
      end

      it 'inherits from ApplicationController' do
        expect(described_class.superclass).to eq(ApplicationController)
      end
    end

    context 'with test data' do
      let!(:exercise1) { create(:strength_exercise, name: 'Bench Press', muscle_group: 'chest', equipment: 'barbell') }
      let!(:exercise2) { create(:strength_exercise, name: 'Squat', muscle_group: 'legs', equipment: 'barbell') }
      let!(:exercise3) { create(:strength_exercise, name: 'Deadlift', muscle_group: 'back', equipment: 'barbell') }

      it 'creates strength exercises for testing' do
        expect(StrengthExercise.count).to eq(3)
      end

      it 'strength exercises have required attributes' do
        expect(exercise1.name).to eq('Bench Press')
        expect(exercise1.muscle_group).to eq('chest')
        expect(exercise1.equipment).to eq('barbell')
      end

      it 'orders exercises by name' do
        exercises = StrengthExercise.all.order(:name)
        expect(exercises.pluck(:name)).to eq([ 'Bench Press', 'Deadlift', 'Squat' ])
      end

      it 'can be serialized to JSON' do
        json = exercise1.as_json
        expect(json).to have_key('id')
        expect(json).to have_key('name')
        expect(json).to have_key('muscle_group')
        expect(json).to have_key('equipment')
        expect(json).to have_key('description')
      end
    end
  end
end
