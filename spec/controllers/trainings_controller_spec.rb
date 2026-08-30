require 'rails_helper'

RSpec.describe TrainingsController, type: :controller do
  after do
    Current.reset
  end

  # Note: GET #index action has been removed - students access trainings directly from dashboard

  describe 'GET #show' do
    context 'when user is a student' do
      let(:user) { create(:user, :complete_student) }
      let(:training) { create(:training, :complete, student_profile: user.student_profile) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'returns http success' do
        get :show, params: { id: training.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested training' do
        get :show, params: { id: training.id }
        expect(assigns(:training)).to eq(training)
      end

      it 'loads strength exercises' do
        get :show, params: { id: training.id }
        expect(assigns(:strength_exercises)).to be_present
      end

      it 'loads mobility exercises' do
        get :show, params: { id: training.id }
        expect(assigns(:mobility_exercises)).to be_present
      end

      it 'loads core exercises' do
        get :show, params: { id: training.id }
        expect(assigns(:core_exercises)).to be_present
      end

      it 'loads cardio exercises' do
        get :show, params: { id: training.id }
        expect(assigns(:cardio_exercises)).to be_present
      end

      it 'displays training information' do
        get :show, params: { id: training.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns training data' do
        get :show, params: { id: training.id }
        expect(assigns(:training)).to eq(training)
      end
    end

    context 'when admin views student training' do
      let(:admin) { create(:user, :admin) }
      let(:student) { create(:user, :complete_student) }
      let(:training) { create(:training, student_profile: student.student_profile) }

      before do
        allow(controller).to receive(:current_user).and_return(admin)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'allows viewing with as parameter' do
        get :show, params: { id: training.id, as: student.id }
        expect(response).to have_http_status(:success)
      end

      it 'does not create workout session for admin' do
        expect {
          get :show, params: { id: training.id, as: student.id }
        }.not_to change { WorkoutSession.count }
      end
    end

    context 'when training does not belong to student' do
      let(:user) { create(:user, :complete_student) }
      let(:other_student) { create(:user, :complete_student) }
      let(:training) { create(:training, student_profile: other_student.student_profile) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'returns error when training does not belong to student' do
        get :show, params: { id: training.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
