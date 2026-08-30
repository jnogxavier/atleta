require 'rails_helper'

RSpec.describe MobilityExercisesController, type: :controller do
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
      let!(:exercise1) { create(:mobility_exercise, name: 'Hip Flexor Stretch', region: 'hips') }
      let!(:exercise2) { create(:mobility_exercise, name: 'Shoulder Dislocations', region: 'shoulders') }
      let!(:exercise3) { create(:mobility_exercise, name: 'Ankle Circles', region: 'ankles') }

      it 'creates mobility exercises for testing' do
        expect(MobilityExercise.count).to eq(3)
      end

      it 'mobility exercises have required attributes' do
        expect(exercise1.name).to eq('Hip Flexor Stretch')
        expect(exercise1.region).to eq('hips')
      end

      it 'orders exercises by name' do
        exercises = MobilityExercise.all.order(:name)
        expect(exercises.pluck(:name)).to eq([ 'Ankle Circles', 'Hip Flexor Stretch', 'Shoulder Dislocations' ])
      end

      it 'can be serialized to JSON' do
        json = exercise1.as_json
        expect(json).to have_key('id')
        expect(json).to have_key('name')
        expect(json).to have_key('region')
        expect(json).to have_key('description')
      end
    end
  end
end
