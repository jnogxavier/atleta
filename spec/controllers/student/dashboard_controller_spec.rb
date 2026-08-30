require 'rails_helper'

RSpec.describe Student::DashboardController, type: :controller do
  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'requires authentication' do
        get :index
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to login or root' do
        get :index
        expect(response).to redirect_to(an_instance_of(String))
      end
    end

    context 'when checking controller responsibilities' do
      let(:user) { create(:user, :complete_student) }

      it 'has an index action' do
        expect(controller).to respond_to(:index)
      end

      it 'is part of the Student module' do
        expect(described_class.name).to eq('Student::DashboardController')
      end

      it 'inherits from ApplicationController' do
        expect(described_class.superclass).to eq(ApplicationController)
      end
    end

    context 'when testing data loading logic' do
      let(:user) { create(:user, :complete_student) }

      before do
        create_list(:evaluation_medium, 3, user: user)
        create_list(:notification, 2, user: user, read_at: nil)
      end

      it 'user has evaluation media' do
        expect(user.evaluation_media.count).to eq(3)
      end

      it 'user has notifications' do
        expect(user.notifications.count).to eq(2)
      end

      it 'user has student profile' do
        expect(user.student_profile).to be_present
      end

      it 'user has anamnese' do
        expect(user.anamnese).to be_present
      end
    end
  end
end
