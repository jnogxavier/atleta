require 'rails_helper'

RSpec.describe Partner::DashboardController, type: :controller do
  after do
    Current.reset
  end

  describe 'GET #index' do
    context 'when user is a partner' do
      let(:partner_user) { create(:user, :complete_partner) }

      before do
        allow(controller).to receive(:current_user).and_return(partner_user)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns the partner profile' do
        get :index
        expect(assigns(:profile)).to eq(partner_user.partner_profile)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is not a partner' do
      let(:student_user) { create(:user, :complete_student) }

      before do
        allow(controller).to receive(:current_user).and_return(student_user)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'sets alert message' do
        get :index
        expect(flash[:alert]).to eq('Acesso restrito aos parceiros.')
      end
    end

    context 'when user is an admin' do
      let(:admin_user) { create(:user, :admin) }

      before do
        allow(controller).to receive(:current_user).and_return(admin_user)
        allow(controller).to receive(:require_authentication).and_return(true)
      end

      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'sets alert message' do
        get :index
        expect(flash[:alert]).to eq('Acesso restrito aos parceiros.')
      end
    end

    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'requires authentication' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
