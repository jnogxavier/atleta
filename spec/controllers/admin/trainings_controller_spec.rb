require 'rails_helper'

RSpec.describe Admin::TrainingsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :complete_student) }
  let(:student_profile) { student.student_profile }
  let!(:strength_exercise) { create(:strength_exercise) }
  let!(:mobility_exercise) { create(:mobility_exercise) }
  let!(:core_exercise) { create(:core_exercise) }
  let!(:cardio_exercise) { create(:cardio_exercise) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:require_authentication).and_return(true)
  end

  after do
    Current.reset
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:require_authentication).and_call_original
      end

      it 'requires authentication' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(student)
      end

      it 'denies access and redirects to root' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'sets alert message' do
        get :index
        expect(flash[:alert]).to eq('You must be an admin to access this page.')
      end
    end

    context 'when user is an admin' do
      let!(:training1) { create(:training, student_profile: student_profile) }
      let!(:training2) { create(:training, student_profile: student_profile) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns all students' do
        get :index
        expect(assigns(:students)).to include(student_profile)
      end

      it 'assigns all trainings' do
        get :index
        expect(assigns(:trainings)).to match_array([ training1, training2 ])
      end

      context 'with student_id parameter' do
        it 'returns JSON for specific student trainings' do
          get :index, params: { student_id: student_profile.id }, format: :json
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(2)
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:training) { create(:training, :complete, student_profile: student_profile) }

    it 'returns JSON with training details' do
      get :show, params: { id: training.id }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(training.id)
      expect(json_response['name']).to eq(training.name)
      expect(json_response['strength_exercises']).to be_an(Array)
      expect(json_response['mobility_exercises']).to be_an(Array)
      expect(json_response['core_exercises']).to be_an(Array)
      expect(json_response['cardio_exercises']).to be_an(Array)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new training' do
      get :new
      expect(assigns(:training)).to be_a_new(Training)
    end

    it 'assigns students' do
      get :new
      expect(assigns(:students)).to include(student_profile)
    end

    it 'assigns all exercise types' do
      get :new
      expect(assigns(:strength_exercises)).to be_present
      expect(assigns(:mobility_exercises)).to be_present
      expect(assigns(:core_exercises)).to be_present
      expect(assigns(:cardio_exercises)).to be_present
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          student_profile_id: student_profile.id,
          training: {
            name: 'Treino A',
            day: 'Monday',
            description: 'Upper body workout',
            active: true
          }
        }
      end

      it 'creates a new training' do
        expect {
          post :create, params: valid_params
        }.to change { Training.count }.by(1)
      end

      it 'associates training with student' do
        post :create, params: valid_params
        training = Training.last
        expect(training.student_profile).to eq(student_profile)
      end

      it 'redirects to trainings index' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_trainings_path)
      end

      it 'sets success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to match(/criado com sucesso/)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          student_profile_id: student_profile.id,
          training: {
            name: '',
            day: 'Monday'
          }
        }
      end

      it 'does not create a training' do
        expect {
          post :create, params: invalid_params
        }.not_to change { Training.count }
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    let!(:training) { create(:training, student_profile: student_profile) }

    it 'returns http success' do
      get :edit, params: { id: training.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested training' do
      get :edit, params: { id: training.id }
      expect(assigns(:training)).to eq(training)
    end

    it 'assigns students and exercises' do
      get :edit, params: { id: training.id }
      expect(assigns(:students)).to be_present
      expect(assigns(:strength_exercises)).to be_present
    end
  end

  describe 'PATCH #update' do
    let!(:training) { create(:training, student_profile: student_profile, name: 'Old Name') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: training.id,
          training: {
            name: 'Updated Name',
            day: 'Tuesday',
            active: false
          }
        }
      end

      it 'updates the training' do
        patch :update, params: valid_params
        training.reload
        expect(training.name).to eq('Updated Name')
        expect(training.day).to eq('Tuesday')
      end

      it 'redirects to trainings index' do
        patch :update, params: valid_params
        expect(response).to redirect_to(admin_trainings_path)
      end

      it 'sets success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to match(/atualizado com sucesso/)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: training.id,
          training: {
            name: ''
          }
        }
      end

      it 'does not update the training' do
        original_name = training.name
        patch :update, params: invalid_params
        training.reload
        expect(training.name).to eq(original_name)
      end

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:training) { create(:training, student_profile: student_profile) }

    it 'destroys the training' do
      expect {
        delete :destroy, params: { id: training.id }
      }.to change { Training.count }.by(-1)
    end

    it 'redirects to trainings index' do
      delete :destroy, params: { id: training.id }
      expect(response).to redirect_to(admin_trainings_path)
    end

    it 'sets success notice' do
      delete :destroy, params: { id: training.id }
      expect(flash[:notice]).to match(/removido com sucesso/)
    end
  end

  describe 'POST #toggle_active' do
    let!(:training) { create(:training, student_profile: student_profile, active: true) }

    it 'toggles training active status' do
      post :toggle_active, params: { id: training.id }
      training.reload
      expect(training.active).to be false
    end

    it 'redirects to trainings index' do
      post :toggle_active, params: { id: training.id }
      expect(response).to redirect_to(admin_trainings_path)
    end

    it 'sets success notice' do
      post :toggle_active, params: { id: training.id }
      expect(flash[:notice]).to be_present
    end
  end

  describe 'GET #search_exercises' do
    let!(:strength_exercise) { create(:strength_exercise, name: 'Bench Press') }

    it 'returns matching exercises as JSON' do
      get :search_exercises, params: { query: 'bench', type: 'strength' }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.first['name']).to eq('Bench Press')
    end

    it 'limits results to 20 exercises' do
      create_list(:strength_exercise, 25)
      get :search_exercises, params: { query: '', type: 'strength' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.length).to be <= 20
    end
  end
end
