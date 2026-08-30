require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #check_email' do
    let(:existing_user) { create(:user, email_address: 'existing@example.com') }

    context 'with valid email format' do
      it 'returns success response to prevent email enumeration' do
        get :check_email, params: { email: 'new@example.com' }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end

      it 'also returns success for existing emails to prevent enumeration' do
        existing_user
        get :check_email, params: { email: 'existing@example.com' }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end

    context 'with invalid email format' do
      it 'returns error response' do
        get :check_email, params: { email: 'invalid' }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('Invalid email format')
      end
    end
  end

  describe 'POST #update_personal_data' do
    context 'with valid data' do
      let(:valid_params) do
        {
          user: {
            name: 'João Silva',
            email_address: 'joao@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a draft user' do
        expect {
          post :update_personal_data, params: valid_params, format: :json
        }.to change { User.count }.by(1)
      end

      it 'sets registration_status to draft' do
        post :update_personal_data, params: valid_params, format: :json
        user = User.last
        expect(user.registration_status).to eq('draft')
      end

      it 'sets role to student' do
        post :update_personal_data, params: valid_params, format: :json
        user = User.last
        expect(user.role).to eq('student')
      end

      it 'stores user id in session' do
        post :update_personal_data, params: valid_params, format: :json
        expect(session[:draft_user_id]).to eq(User.last.id)
      end

      it 'returns success response' do
        post :update_personal_data, params: valid_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['user_id']).to be_present
      end
    end

    context 'with duplicate email' do
      let!(:existing_user) { create(:user, email_address: 'existing@example.com') }

      let(:invalid_params) do
        {
          user: {
            name: 'João Silva',
            email_address: 'existing@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :update_personal_data, params: invalid_params, format: :json
        }.not_to change { User.count }
      end

      it 'returns error response' do
        post :update_personal_data, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to include('Email já está em uso')
      end
    end

    context 'with short password' do
      let(:invalid_params) do
        {
          user: {
            name: 'João Silva',
            email_address: 'joao@example.com',
            password: '123',
            password_confirmation: '123'
          }
        }
      end

      it 'returns error response' do
        post :update_personal_data, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Senha deve ter no mínimo 8 caracteres')
      end
    end

    context 'with mismatched password confirmation' do
      let(:invalid_params) do
        {
          user: {
            name: 'João Silva',
            email_address: 'joao@example.com',
            password: 'password123',
            password_confirmation: 'different123'
          }
        }
      end

      it 'returns error response' do
        post :update_personal_data, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Confirmação de senha não coincide')
      end
    end

    context 'when updating existing draft user' do
      let(:draft_user) { create(:user, :draft_student) }

      before do
        session[:draft_user_id] = draft_user.id
      end

      it 'updates the existing user' do
        expect {
          post :update_personal_data, params: {
            user: {
              name: 'Updated Name',
              email_address: draft_user.email_address,
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }, format: :json
        }.not_to change { User.count }

        draft_user.reload
        expect(draft_user.name).to eq('Updated Name')
      end
    end
  end

  describe 'POST #update_anamnese' do
    let(:draft_user) { create(:user, :draft_student) }

    before do
      session[:draft_user_id] = draft_user.id
    end

    context 'with valid anamnese data' do
      let(:valid_anamnese_params) do
        anamnese_attrs = attributes_for(:anamnese)
        # eating_motivation should be an array for the controller
        anamnese_attrs[:eating_motivation] = [ "Ganhar massa", "Melhorar saúde" ]
        {
          user: {
            anamnese_attributes: anamnese_attrs
          }
        }
      end

      it 'creates anamnese for the user' do
        expect {
          post :update_anamnese, params: valid_anamnese_params, format: :json
        }.to change { Anamnese.count }.by(1)
      end

      it 'returns success response' do
        post :update_anamnese, params: valid_anamnese_params, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end

      it 'associates anamnese with user' do
        post :update_anamnese, params: valid_anamnese_params, format: :json
        draft_user.reload
        expect(draft_user.anamnese).to be_present
      end
    end

    context 'when updating existing anamnese' do
      let!(:anamnese) { create(:anamnese, user: draft_user) }

      it 'updates existing anamnese' do
        new_age = anamnese.age + 5
        expect {
          post :update_anamnese, params: {
            user: {
              anamnese_attributes: attributes_for(:anamnese).merge(age: new_age)
            }
          }, format: :json
        }.not_to change { Anamnese.count }

        anamnese.reload
        expect(anamnese.age).to eq(new_age)
      end
    end

    context 'when user not found' do
      before do
        session[:draft_user_id] = nil
      end

      it 'returns unprocessable entity response' do
        post :update_anamnese, params: {
          user: { anamnese_attributes: { age: 30 } }
        }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Registration session not found. Please start over.')
      end
    end
  end

  describe 'POST #finalize' do
    context 'when user not found' do
      before do
        session[:draft_user_id] = nil
      end

      it 'returns unprocessable entity response' do
        post :finalize, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Registration session not found. Please start over.')
      end
    end

    # Note: Testing the complete finalize flow requires complex setup with password digests
    # and all anamnese fields. This is tested through integration/system tests.
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          name: 'Maria Silva',
          email_address: 'maria@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          terms_accepted: true
        }
      }
    end

    before do
      allow(controller).to receive(:start_new_session_for)
    end

    context 'with valid parameters' do
      it 'creates a pending registration' do
        expect {
          post :create, params: valid_params
        }.to change { PendingRegistration.count }.by(1)
      end

      it 'sets pending registration email' do
        post :create, params: valid_params
        pending_reg = PendingRegistration.last
        expect(pending_reg.email).to eq('maria@example.com')
      end

      it 'stores user data in session' do
        post :create, params: valid_params
        expect(session[:pending_user_data]).to include(
          name: 'Maria Silva',
          email_address: 'maria@example.com'
        )
      end

      it 'sets pending registration status' do
        post :create, params: valid_params
        pending_reg = PendingRegistration.last
        expect(pending_reg.status).to eq('pending')
      end

      it 'redirects to root with notice' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Cadastro realizado com sucesso")
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            name: '',
            email_address: 'invalid',
            password: '123',
            password_confirmation: '123'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: invalid_params
        }.not_to change { User.count }
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
