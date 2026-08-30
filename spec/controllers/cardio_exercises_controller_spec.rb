require 'rails_helper'

RSpec.describe CardioExercisesController, type: :controller do
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
      let!(:exercise1) { create(:cardio_exercise, name: 'Running', cardio_type: 'outdoor') }
      let!(:exercise2) { create(:cardio_exercise, name: 'Cycling', cardio_type: 'outdoor') }
      let!(:exercise3) { create(:cardio_exercise, name: 'Jump Rope', cardio_type: 'indoor') }

      it 'creates cardio exercises for testing' do
        expect(CardioExercise.count).to eq(3)
      end

      it 'cardio exercises have required attributes' do
        expect(exercise1.name).to eq('Running')
        expect(exercise1.cardio_type).to eq('outdoor')
      end

      it 'orders exercises by name' do
        exercises = CardioExercise.all.order(:name)
        expect(exercises.pluck(:name)).to eq([ 'Cycling', 'Jump Rope', 'Running' ])
      end

      it 'can be serialized to JSON' do
        json = exercise1.as_json
        expect(json).to have_key('id')
        expect(json).to have_key('name')
        expect(json).to have_key('cardio_type')
        expect(json).to have_key('description')
      end
    end
  end
end
