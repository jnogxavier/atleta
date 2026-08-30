require 'rails_helper'

RSpec.describe Admin::EvaluationMediaController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :complete_student) }

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
        get :index, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(student)
      end

      it 'denies access and redirects to root' do
        get :index, format: :json
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is an admin' do
      let!(:media1) { create(:evaluation_medium, user: student) }
      let!(:media2) { create(:evaluation_medium, user: student) }

      it 'returns JSON with all media' do
        get :index, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(2)
      end

      context 'filtering by student_id' do
        let(:other_student) { create(:user, :complete_student) }
        let!(:other_media) { create(:evaluation_medium, user: other_student) }

        it 'returns only media for specified student' do
          get :index, params: { student_id: student.id }, format: :json
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response.length).to eq(2)
          expect(json_response.all? { |m| m['student_name'].present? }).to be true
        end
      end

      context 'filtering by status pending' do
        let!(:pending_media) { create(:evaluation_medium, :pending, user: student) }
        let!(:evaluated_media) { create(:evaluation_medium, :evaluated, user: student) }

        it 'returns only pending media' do
          get :index, params: { status: 'pending' }, format: :json
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          pending_count = json_response.count { |m| m['evaluated'] == false }
          expect(pending_count).to be >= 1
        end
      end

      context 'filtering by status evaluated' do
        let!(:pending_media) { create(:evaluation_medium, :pending, user: student) }
        let!(:evaluated_media) { create(:evaluation_medium, :evaluated, user: student) }

        it 'returns only evaluated media' do
          get :index, params: { status: 'evaluated' }, format: :json
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          evaluated_count = json_response.count { |m| m['evaluated'] == true }
          expect(evaluated_count).to be >= 1
        end
      end

      context 'filtering by media type' do
        let!(:photo) { create(:evaluation_medium, :photo, user: student) }
        let!(:video) { create(:evaluation_medium, :video, user: student) }

        it 'returns only media of specified type' do
          get :index, params: { type: 'photo' }, format: :json
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response.all? { |m| m['media_type'] == 'photo' }).to be true
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:medium) { create(:evaluation_medium, user: student) }

    context 'when user is an admin' do
      it 'returns JSON with medium details' do
        get :show, params: { id: medium.id }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(medium.id)
        expect(json_response['student_name']).to be_present
        expect(json_response['media_type']).to eq(medium.media_type)
      end

      it 'includes student profile name if available' do
        get :show, params: { id: medium.id }, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['student_name']).to eq(student.student_profile.name)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:medium) { create(:evaluation_medium, :pending, user: student) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: medium.id,
          admin_notes: 'Great progress! Keep it up.',
          evaluated: true
        }
      end

      it 'updates the evaluation medium' do
        patch :update, params: valid_params, format: :json
        medium.reload
        expect(medium.admin_notes).to eq('Great progress! Keep it up.')
        expect(medium.evaluated).to be true
      end

      it 'returns success JSON response' do
        patch :update, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end

    context 'marking as evaluated without notes' do
      let(:params) do
        {
          id: medium.id,
          evaluated: true
        }
      end

      it 'updates evaluated status' do
        patch :update, params: params, format: :json
        medium.reload
        expect(medium.evaluated).to be true
      end
    end

    context 'adding admin notes without marking as evaluated' do
      let(:params) do
        {
          id: medium.id,
          admin_notes: 'Need better lighting in photos',
          evaluated: false
        }
      end

      it 'updates admin notes' do
        patch :update, params: params, format: :json
        medium.reload
        expect(medium.admin_notes).to eq('Need better lighting in photos')
        expect(medium.evaluated).to be false
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: medium.id,
          media_type: 'invalid_type'
        }
      end

      it 'does not update restricted attributes' do
        original_type = medium.media_type
        patch :update, params: invalid_params, format: :json
        medium.reload
        expect(medium.media_type).to eq(original_type)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:medium) { create(:evaluation_medium, user: student) }

    it 'destroys the evaluation medium' do
      expect {
        delete :destroy, params: { id: medium.id }, format: :json
      }.to change { EvaluationMedium.count }.by(-1)
    end

    it 'returns success JSON response' do
      delete :destroy, params: { id: medium.id }, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end

    context 'with non-existent medium' do
      it 'returns error for non-existent medium' do
        delete :destroy, params: { id: 99999 }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'combined filtering scenarios' do
    let(:student1) { create(:user, :complete_student) }
    let(:student2) { create(:user, :complete_student) }
    let!(:student1_pending_photo) { create(:evaluation_medium, :pending, :photo, user: student1) }
    let!(:student1_evaluated_photo) { create(:evaluation_medium, :evaluated, :photo, user: student1) }
    let!(:student2_pending_video) { create(:evaluation_medium, :pending, :video, user: student2) }

    context 'filtering by student and status' do
      it 'returns media matching both filters' do
        get :index, params: { student_id: student1.id, status: 'pending' }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.length).to be >= 1
        expect(json_response.all? { |m| m['evaluated'] == false }).to be true
      end
    end

    context 'filtering by status and type' do
      it 'returns media matching both filters' do
        get :index, params: { status: 'pending', type: 'photo' }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.length).to be >= 1
        expect(json_response.all? { |m| m['media_type'] == 'photo' && m['evaluated'] == false }).to be true
      end
    end
  end
end
