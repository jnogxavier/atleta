require 'rails_helper'

RSpec.describe Admin::CardioExercisesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :complete_student) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:require_authentication).and_return(true)
  end

  after do
    Current.reset
  end

  describe 'GET #show' do
    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:require_authentication).and_call_original
      end

      it 'requires authentication' do
        exercise = create(:cardio_exercise)
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(student)
      end

      it 'denies access and redirects to root' do
        exercise = create(:cardio_exercise)
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is an admin' do
      let!(:exercise) { create(:cardio_exercise, name: 'Running', cardio_type: 'treadmill') }

      it 'returns JSON with exercise details' do
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(exercise.id)
        expect(json_response['name']).to eq('Running')
        expect(json_response['cardio_type']).to eq('treadmill')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          cardio_exercise: {
            name: 'Cycling',
            cardio_type: 'bike',
            description: 'Low impact cardio'
          }
        }
      end

      it 'creates a new cardio exercise' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change { CardioExercise.count }.by(1)
      end

      it 'returns success JSON response' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['exercise']['name']).to eq('Cycling')
      end

      it 'creates exercise with correct attributes' do
        post :create, params: valid_params, format: :json
        exercise = CardioExercise.last
        expect(exercise.name).to eq('Cycling')
        expect(exercise.cardio_type).to eq('bike')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          cardio_exercise: {
            name: '',
            cardio_type: 'treadmill'
          }
        }
      end

      it 'does not create a cardio exercise' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change { CardioExercise.count }
      end

      it 'returns error JSON response' do
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to be_present
      end
    end

    context 'with HTML format' do
      let(:valid_params) do
        {
          cardio_exercise: {
            name: 'Jump Rope',
            cardio_type: 'rope'
          }
        }
      end

      it 'redirects to admin dashboard' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it 'sets success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Exercício criado com sucesso!')
      end
    end
  end

  describe 'PATCH #update' do
    let!(:exercise) { create(:cardio_exercise, name: 'Old Name', cardio_type: 'treadmill') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: exercise.id,
          cardio_exercise: {
            name: 'Updated Running',
            cardio_type: 'outdoor',
            description: 'Fresh air cardio'
          }
        }
      end

      it 'updates the cardio exercise' do
        patch :update, params: valid_params, format: :json
        exercise.reload
        expect(exercise.name).to eq('Updated Running')
        expect(exercise.cardio_type).to eq('outdoor')
      end

      it 'returns success JSON response' do
        patch :update, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: exercise.id,
          cardio_exercise: {
            name: ''
          }
        }
      end

      it 'does not update the exercise' do
        original_name = exercise.name
        patch :update, params: invalid_params, format: :json
        exercise.reload
        expect(exercise.name).to eq(original_name)
      end

      it 'returns error JSON response' do
        patch :update, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:exercise) { create(:cardio_exercise) }

    it 'destroys the cardio exercise' do
      expect {
        delete :destroy, params: { id: exercise.id }, format: :json
      }.to change { CardioExercise.count }.by(-1)
    end

    it 'returns success JSON response' do
      delete :destroy, params: { id: exercise.id }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end

    context 'with HTML format' do
      it 'redirects to admin dashboard' do
        delete :destroy, params: { id: exercise.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it 'sets success notice' do
        delete :destroy, params: { id: exercise.id }
        expect(flash[:notice]).to eq('Exercício excluído com sucesso!')
      end
    end
  end
end
