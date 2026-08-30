require 'rails_helper'

RSpec.describe 'Student Dashboard', type: :request do
  let(:student) { create(:user, :student) }
  let(:admin) { create(:user, :admin) }

  before do
    post session_path, params: { email_address: student.email_address, password: student.password }
  end

  describe 'GET /student/dashboard' do
    context 'when student has no profile' do
      it 'renders successfully without errors' do
        get student_dashboard_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Bem-vindo')
      end
    end

    context 'when student has a profile' do
      let!(:profile) { create(:student_profile, user: student, name: 'Test Student') }

      it 'renders successfully with profile' do
        get student_dashboard_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Bem-vindo')
      end
    end
  end

  describe 'Admin viewing as student' do
    before do
      delete logout_path
      post session_path, params: { email_address: admin.email_address, password: admin.password }
    end

    context 'when student has no profile' do
      it 'renders successfully without errors' do
        get student_dashboard_path(as: student.id)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Bem-vindo')
      end
    end

    context 'when student has a profile' do
      let!(:profile) { create(:student_profile, user: student, name: 'João Silva') }

      it 'renders successfully with profile' do
        get student_dashboard_path(as: student.id)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Bem-vindo')
      end
    end
  end
end
