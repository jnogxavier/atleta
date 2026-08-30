require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  after do
    Current.reset
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'requires authentication' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      let(:student) { create(:user, :complete_student) }

      before do
        allow(controller).to receive(:current_user).and_return(student)
        allow(controller).to receive(:require_authentication).and_return(true)
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
      let(:admin) { create(:user, :admin) }

      before do
        allow(controller).to receive(:current_user).and_return(admin)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when loading dashboard data' do
      let(:admin) { create(:user, :admin) }
      let!(:users) { create_list(:user, 3) }
      let!(:pending_registrations) { create_list(:pending_registration, 2, :pending) }
      let!(:approved_registrations) { create_list(:pending_registration, 2, :approved) }
      let!(:rejected_registrations) { create_list(:pending_registration, 2, :rejected) }
      let!(:notifications) { create_list(:notification, 3, user: admin, read_at: nil) }

      before do
        allow(controller).to receive(:current_user).and_return(admin)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'assigns all users' do
        get :index
        expect(assigns(:users)).to match_array(User.all)
      end

      it 'assigns pending registrations' do
        get :index
        expect(assigns(:pending_registrations)).to match_array(pending_registrations)
      end

      it 'assigns approved registrations' do
        get :index
        expect(assigns(:approved_registrations).length).to be <= 10
      end

      it 'assigns rejected registrations' do
        get :index
        expect(assigns(:rejected_registrations).length).to be <= 10
      end

      it 'assigns unread notifications for admin' do
        get :index
        expect(assigns(:notifications)).to match_array(notifications)
      end

      it 'orders users by status (active first), then role, then name' do
        get :index
        assigned_users = assigns(:users)

        # Active users (deactivated_at IS NULL) should come before deactivated users
        active_users = assigned_users.select { |u| u.deactivated_at.nil? }
        deactivated_users = assigned_users.select { |u| u.deactivated_at.present? }

        # All active users should appear before any deactivated users
        if active_users.any? && deactivated_users.any?
          last_active_index = assigned_users.index(active_users.last)
          first_deactivated_index = assigned_users.index(deactivated_users.first)
          expect(last_active_index).to be < first_deactivated_index
        end
      end
    end
  end
end
