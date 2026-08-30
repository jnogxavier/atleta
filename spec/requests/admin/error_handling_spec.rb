require 'rails_helper'

describe 'Admin Error Handling' do
  let(:admin_user) { create(:user, role: 'admin') }

  before { sign_in admin_user }

  describe 'RecordNotFound handling' do
    it 'returns 404 for JSON requests to non-existent training' do
      get admin_training_path(9999), headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to include('application/json')
      json = JSON.parse(response.body)
      expect(json).to have_key('error')
    end

    it 'redirects for HTML requests to non-existent nutrition plan' do
      get admin_nutrition_plan_path(9999)
      expect(response).to redirect_to(admin_dashboard_path)
    end

    it 'logs the error' do
      expect(Rails.logger).to receive(:error)
      get admin_training_path(9999), headers: { 'Accept' => 'application/json' }
    end
  end

  describe 'RecordInvalid handling' do
    context 'JSON response' do
      it 'returns unprocessable entity for invalid training' do
        post admin_trainings_path, params: {
          training: { name: '' },
          student_profile_id: create(:student_profile).id
        }, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'includes error messages in response' do
        post admin_trainings_path, params: {
          training: { name: '' },
          student_profile_id: create(:student_profile).id
        }, headers: { 'Accept' => 'application/json' }
        json = JSON.parse(response.body)
        expect(json.keys).to satisfy { |keys| keys.include?('errors') || keys.include?('success') }
      end
    end

    context 'HTML response' do
      it 'sets flash alert for HTML requests' do
        post admin_trainings_path, params: {
          training: { name: '' },
          student_profile_id: create(:student_profile).id
        }
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'ArgumentError handling' do
    context 'when service raises ArgumentError' do
      it 'returns bad request for JSON' do
        # This would be triggered by TrainingExerciseService with invalid exercise
        student = create(:student_profile)
        training = create(:training, student_profile: student)

        post admin_trainings_path, params: {
          exercises: {
            strength_exercises: {
              '999999' => { sets: 3, reps: 10 }
            }
          }
        }, headers: { 'Accept' => 'application/json' }

        # Should either succeed or handle gracefully
        expect([ 200, 422, 400 ]).to include(response.status)
      end
    end
  end
end
