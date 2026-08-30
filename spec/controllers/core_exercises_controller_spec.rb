require 'rails_helper'

RSpec.describe CoreExercisesController, type: :controller do
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
      let!(:exercise1) { create(:core_exercise, name: 'Plank', category: 'stability') }
      let!(:exercise2) { create(:core_exercise, name: 'Crunches', category: 'flexion') }
      let!(:exercise3) { create(:core_exercise, name: 'Russian Twist', category: 'rotation') }

      it 'creates core exercises for testing' do
        expect(CoreExercise.count).to eq(3)
      end

      it 'core exercises have required attributes' do
        expect(exercise1.name).to eq('Plank')
        expect(exercise1.category).to eq('stability')
      end

      it 'orders exercises by name' do
        exercises = CoreExercise.all.order(:name)
        expect(exercises.pluck(:name)).to eq([ 'Crunches', 'Plank', 'Russian Twist' ])
      end

      it 'can be serialized to JSON' do
        json = exercise1.as_json
        expect(json).to have_key('id')
        expect(json).to have_key('name')
        expect(json).to have_key('category')
        expect(json).to have_key('description')
      end
    end
  end
end
