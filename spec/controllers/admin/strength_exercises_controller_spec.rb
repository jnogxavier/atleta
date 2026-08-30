require 'rails_helper'

RSpec.describe Admin::StrengthExercisesController, type: :controller do
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
        exercise = create(:strength_exercise)
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(student)
      end

      it 'denies access and redirects to root' do
        exercise = create(:strength_exercise)
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is an admin' do
      let!(:exercise) { create(:strength_exercise, name: 'Bench Press', muscle_group: 'chest', equipment: 'barbell') }

      it 'returns JSON with exercise details' do
        get :show, params: { id: exercise.id }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(exercise.id)
        expect(json_response['name']).to eq('Bench Press')
        expect(json_response['muscle_group']).to eq('chest')
        expect(json_response['equipment']).to eq('barbell')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          strength_exercise: {
            name: 'Squat',
            muscle_group: 'legs',
            equipment: 'barbell',
            description: 'Compound leg exercise'
          }
        }
      end

      it 'creates a new strength exercise' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change { StrengthExercise.count }.by(1)
      end

      it 'returns success JSON response' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['exercise']['name']).to eq('Squat')
      end

      it 'creates exercise with correct attributes' do
        post :create, params: valid_params, format: :json
        exercise = StrengthExercise.last
        expect(exercise.name).to eq('Squat')
        expect(exercise.muscle_group).to eq('legs')
        expect(exercise.equipment).to eq('barbell')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          strength_exercise: {
            name: '',
            muscle_group: 'legs'
          }
        }
      end

      it 'does not create a strength exercise' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change { StrengthExercise.count }
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
          strength_exercise: {
            name: 'Deadlift',
            muscle_group: 'back',
            equipment: 'barbell'
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
    let!(:exercise) { create(:strength_exercise, name: 'Old Name', muscle_group: 'chest') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: exercise.id,
          strength_exercise: {
            name: 'Updated Name',
            muscle_group: 'back',
            equipment: 'cable'
          }
        }
      end

      it 'updates the strength exercise' do
        patch :update, params: valid_params, format: :json
        exercise.reload
        expect(exercise.name).to eq('Updated Name')
        expect(exercise.muscle_group).to eq('back')
        expect(exercise.equipment).to eq('cable')
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
          strength_exercise: {
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
    let!(:exercise) { create(:strength_exercise) }

    it 'destroys the strength exercise' do
      expect {
        delete :destroy, params: { id: exercise.id }, format: :json
      }.to change { StrengthExercise.count }.by(-1)
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
