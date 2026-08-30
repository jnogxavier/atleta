require 'rails_helper'

RSpec.describe Admin::VideosController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :complete_student) }
  let(:student_profile) { student.student_profile }

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
      let!(:video1) { create(:video, :for_strength) }
      let!(:video2) { create(:video, :for_strength) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns all videos' do
        get :index
        expect(assigns(:videos)).to match_array([ video1, video2 ])
      end

      context 'with student_id parameter' do
        let!(:student_video) { create(:video, videoable: student_profile) }

        it 'assigns videos for specific student' do
          get :index, params: { student_id: student_profile.id }
          expect(response).to have_http_status(:success)
          expect(assigns(:videos)).to include(student_video)
        end
      end

      context 'with videoable_type and videoable_id parameters' do
        let!(:exercise) { create(:strength_exercise) }
        let!(:exercise_video) { create(:video, videoable: exercise) }

        it 'returns JSON for exercise videos' do
          get :index, params: { videoable_type: 'StrengthExercise', videoable_id: exercise.id }, format: :json
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.first['id']).to eq(exercise_video.id)
        end

        it 'rejects invalid videoable types' do
          get :index, params: { videoable_type: 'InvalidType', videoable_id: 1 }, format: :json
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new, params: { student_id: student_profile.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new video for student' do
      get :new, params: { student_id: student_profile.id }
      expect(assigns(:video)).to be_a_new(Video)
      expect(assigns(:video).videoable).to eq(student_profile)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters for student video' do
      let(:valid_params) do
        {
          student_id: student_profile.id,
          video: {
            url: 'https://www.youtube.com/watch?v=test123',
            description: 'Sample training video'
          }
        }
      end

      it 'creates a new video' do
        expect {
          post :create, params: valid_params
        }.to change { Video.count }.by(1)
      end

      it 'associates video with student profile' do
        post :create, params: valid_params
        video = Video.last
        expect(video.videoable).to eq(student_profile)
      end

      it 'redirects to student videos path' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_student_videos_path(student_profile))
      end

      it 'sets success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Vídeo adicionado com sucesso!')
      end
    end

    context 'with valid parameters for exercise video' do
      let(:exercise) { create(:strength_exercise) }
      let(:valid_params) do
        {
          videoable_type: 'StrengthExercise',
          videoable_id: exercise.id,
          video: {
            url: 'https://www.youtube.com/watch?v=demo456'
          }
        }
      end

      it 'creates a new video for exercise' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change { Video.count }.by(1)
      end

      it 'returns success JSON response' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end

    context 'with invalid videoable type' do
      let(:invalid_params) do
        {
          videoable_type: 'InvalidModel',
          videoable_id: 1,
          video: {
            url: 'https://www.youtube.com/watch?v=test'
          }
        }
      end

      it 'does not create a video' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change { Video.count }
      end

      it 'returns bad request status' do
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          student_id: student_profile.id,
          video: {
            url: ''
          }
        }
      end

      it 'does not create a video' do
        expect {
          post :create, params: invalid_params
        }.not_to change { Video.count }
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
    let!(:video) { create(:video, videoable: student_profile) }

    it 'returns http success' do
      get :edit, params: { id: video.id, student_id: student_profile.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested video' do
      get :edit, params: { id: video.id, student_id: student_profile.id }
      expect(assigns(:video)).to eq(video)
    end
  end

  describe 'PATCH #update' do
    let!(:video) { create(:video, videoable: student_profile, description: 'Old description') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: video.id,
          student_id: student_profile.id,
          video: {
            url: 'https://www.youtube.com/watch?v=updated',
            description: 'Updated description'
          }
        }
      end

      it 'updates the video' do
        patch :update, params: valid_params
        video.reload
        expect(video.description).to eq('Updated description')
        expect(video.url).to eq('https://www.youtube.com/watch?v=updated')
      end

      it 'redirects to student videos path' do
        patch :update, params: valid_params
        expect(response).to redirect_to(admin_student_videos_path(student_profile))
      end

      it 'sets success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Vídeo atualizado com sucesso!')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: video.id,
          student_id: student_profile.id,
          video: {
            url: ''
          }
        }
      end

      it 'does not update the video' do
        original_url = video.url
        patch :update, params: invalid_params
        video.reload
        expect(video.url).to eq(original_url)
      end

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:video) { create(:video, videoable: student_profile) }

    it 'destroys the video' do
      expect {
        delete :destroy, params: { id: video.id, student_id: student_profile.id }
      }.to change { Video.count }.by(-1)
    end

    it 'redirects to student videos path' do
      delete :destroy, params: { id: video.id, student_id: student_profile.id }
      expect(response).to redirect_to(admin_student_videos_path(student_profile))
    end

    it 'sets success notice' do
      delete :destroy, params: { id: video.id, student_id: student_profile.id }
      expect(flash[:notice]).to eq('Vídeo removido com sucesso!')
    end

    context 'with JSON format' do
      let!(:exercise_video) { create(:video, :for_strength) }

      it 'returns success JSON response' do
        delete :destroy, params: { id: exercise_video.id }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end
  end
end
