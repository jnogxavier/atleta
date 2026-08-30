require 'rails_helper'

RSpec.describe Admin::CoreExercisesController, type: :controller do
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
        exercise = create(:core_exercise)
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(student)
      end

      it 'denies access and redirects to root' do
        exercise = create(:core_exercise)
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is an admin' do
      let!(:exercise) { create(:core_exercise, name: 'Plank', description: 'Static core hold') }

      it 'returns JSON with exercise details' do
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(exercise.id)
        expect(json_response['name']).to eq('Plank')
        expect(json_response['description']).to eq('Static core hold')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          core_exercise: {
            name: 'Crunches',
            description: 'Classic ab exercise'
          }
        }
      end

      it 'creates a new core exercise' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change { CoreExercise.count }.by(1)
      end

      it 'returns success JSON response' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['exercise']['name']).to eq('Crunches')
      end

      it 'creates exercise with correct attributes' do
        post :create, params: valid_params, format: :json
        exercise = CoreExercise.last
        expect(exercise.name).to eq('Crunches')
        expect(exercise.description).to eq('Classic ab exercise')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          core_exercise: {
            name: '',
            description: 'Some description'
          }
        }
      end

      it 'does not create a core exercise' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change { CoreExercise.count }
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
          core_exercise: {
            name: 'Russian Twist',
            description: 'Rotational core movement'
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
    let!(:exercise) { create(:core_exercise, name: 'Old Name', description: 'Old description') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: exercise.id,
          core_exercise: {
            name: 'Updated Plank',
            description: 'Updated description for plank'
          }
        }
      end

      it 'updates the core exercise' do
        patch :update, params: valid_params, format: :json
        exercise.reload
        expect(exercise.name).to eq('Updated Plank')
        expect(exercise.description).to eq('Updated description for plank')
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
          core_exercise: {
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
    let!(:exercise) { create(:core_exercise) }

    it 'destroys the core exercise' do
      expect {
        delete :destroy, params: { id: exercise.id }, format: :json
      }.to change { CoreExercise.count }.by(-1)
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
