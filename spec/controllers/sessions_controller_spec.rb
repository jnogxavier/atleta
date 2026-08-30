require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    context 'when user is not authenticated' do
      it 'returns http success' do
        get :new
        expect(response).to have_http_status(:success)
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when user is already authenticated' do
      let(:user) { create(:user, :complete_student) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:dashboard_path_for).with(user).and_return('/student/dashboard')
      end

      it 'redirects to user dashboard' do
        get :new
        expect(response).to redirect_to('/student/dashboard')
      end
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    context 'with valid credentials' do
      before do
        allow(controller).to receive(:start_new_session_for)
        allow(controller).to receive(:dashboard_path_for).with(user).and_return('/student/dashboard')
      end

      it 'authenticates the user' do
        post :create, params: { email_address: user.email_address, password: 'password123' }
        expect(response).to redirect_to('/student/dashboard')
      end

      it 'sets a success notice' do
        post :create, params: { email_address: user.email_address, password: 'password123' }
        expect(flash[:notice]).to eq('Login realizado com sucesso!')
      end

      it 'starts a new session' do
        expect(controller).to receive(:start_new_session_for).with(user)
        post :create, params: { email_address: user.email_address, password: 'password123' }
      end
    end

    context 'with invalid credentials' do
      it 'redirects back to login' do
        post :create, params: { email_address: 'wrong@example.com', password: 'wrongpassword' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets an error alert' do
        post :create, params: { email_address: 'wrong@example.com', password: 'wrongpassword' }
        expect(flash[:alert]).to eq('E-mail ou senha incorretos.')
      end

      it 'does not start a session' do
        expect(controller).not_to receive(:start_new_session_for)
        post :create, params: { email_address: 'wrong@example.com', password: 'wrongpassword' }
      end
    end

    context 'with empty credentials' do
      it 'handles empty email and password' do
        post :create, params: { email_address: '', password: '' }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq('E-mail ou senha incorretos.')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'redirects to login page' do
      delete :destroy
      expect(response).to redirect_to(new_session_path)
    end

    it 'has redirect status' do
      delete :destroy
      expect(response).to have_http_status(:redirect)
    end
  end
end
