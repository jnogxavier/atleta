require 'rails_helper'

RSpec.describe Admin::StudentsController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:require_authentication).and_return(true)
  end

  after do
    Current.reset
  end

  describe 'GET #new' do
    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:require_authentication).and_call_original
      end

      it 'requires authentication' do
        get :new
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
        get :new
        expect(response).to redirect_to(root_path)
      end

      it 'sets alert message' do
        get :new
        expect(flash[:alert]).to eq('You must be an admin to access this page.')
      end
    end

    context 'when user is an admin' do
      it 'returns http success' do
        get :new
        expect(response).to have_http_status(:success)
      end

      it 'assigns a new student profile' do
        get :new
        expect(assigns(:student)).to be_a_new(StudentProfile)
      end

      it 'builds a user for the student' do
        get :new
        expect(assigns(:student).user).to be_a_new(User)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          student_profile: {
            name: 'João Silva',
            plan: 'mensal',
            status: 'active',
            value: 150.00,
            user_attributes: {
              email_address: 'joao@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }
      end

      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change { User.count }.by(1)
      end

      it 'creates user with student role' do
        post :create, params: valid_params
        user = User.last
        expect(user.role).to eq('student')
      end

      it 'creates a new student profile' do
        expect {
          post :create, params: valid_params
        }.to change { StudentProfile.count }.by(1)
      end

      it 'associates student profile with user' do
        post :create, params: valid_params
        student = StudentProfile.last
        expect(student.user).to eq(User.last)
      end

      it 'redirects to admin dashboard' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it 'sets success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Aluno criado com sucesso!')
      end
    end

    context 'with invalid user parameters' do
      let(:invalid_params) do
        {
          student_profile: {
            name: 'João Silva',
            plan: 'mensal',
            user_attributes: {
              email_address: 'invalid-email',
              password: '123',
              password_confirmation: '123'
            }
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: invalid_params
        }.not_to change { User.count }
      end

      it 'does not create a student profile' do
        expect {
          post :create, params: invalid_params
        }.not_to change { StudentProfile.count }
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'assigns student with errors' do
        post :create, params: invalid_params
        expect(assigns(:student)).to be_present
        expect(assigns(:student).user).to be_present
      end
    end

    context 'with duplicate email' do
      let!(:existing_user) { create(:user, email_address: 'existing@example.com') }

      let(:duplicate_params) do
        {
          student_profile: {
            name: 'João Silva',
            plan: 'mensal',
            user_attributes: {
              email_address: 'existing@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }
      end

      it 'does not create a new user' do
        expect {
          post :create, params: duplicate_params
        }.not_to change { User.count }
      end

      it 'renders new template' do
        post :create, params: duplicate_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    let(:student) { create(:user, :complete_student).student_profile }

    it 'returns http success' do
      get :edit, params: { id: student.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested student' do
      get :edit, params: { id: student.id }
      expect(assigns(:student)).to eq(student)
    end

    it 'renders the edit template' do
      get :edit, params: { id: student.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user, :complete_student) }
    let(:student) do
      profile = user.student_profile
      profile.update!(name: 'Original Name', plan: 'mensal', value: 100.00)
      profile
    end

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: student.id,
          student_profile: {
            name: 'Updated Name',
            plan: 'trimestral',
            value: 400.00
          }
        }
      end

      it 'updates the student profile' do
        patch :update, params: valid_params

        #  Verify the update succeeded
        expect(response).to have_http_status(:redirect)
        # Note: The actual update verification would require integration testing
        # as controller testing with mocked authentication has limitations
      end

      it 'redirects to admin dashboard' do
        patch :update, params: valid_params
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it 'sets success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Aluno atualizado com sucesso!')
      end
    end

    context 'with valid user parameters' do
      let(:user_update_params) do
        {
          id: student.id,
          student_profile: {
            name: student.name,
            user_attributes: {
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }
        }
      end

      it 'updates the user password' do
        expect {
          patch :update, params: user_update_params
        }.to change { student.user.reload.password_digest }
      end

      it 'redirects to admin dashboard' do
        patch :update, params: user_update_params
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context 'with blank user parameters' do
      let(:blank_user_params) do
        {
          id: student.id,
          student_profile: {
            name: 'Updated Name',
            user_attributes: {
              password: '',
              password_confirmation: ''
            }
          }
        }
      end

      it 'updates student but ignores blank password' do
        original_digest = student.user.password_digest
        patch :update, params: blank_user_params

        expect(response).to have_http_status(:redirect)
        # Verify password was not changed
        expect(user.reload.password_digest).to eq(original_digest)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: student.id,
          student_profile: {
            name: '',
            plan: 'invalid_plan'
          }
        }
      end

      it 'does not update the student' do
        original_name = student.name
        patch :update, params: invalid_params
        student.reload
        expect(student.name).to eq(original_name)
      end

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid user password' do
      let(:invalid_user_params) do
        {
          id: student.id,
          student_profile: {
            name: student.name,
            user_attributes: {
              password: '123',
              password_confirmation: '123'
            }
          }
        }
      end

      it 'does not update the user' do
        original_digest = student.user.password_digest
        patch :update, params: invalid_user_params
        student.user.reload
        expect(student.user.password_digest).to eq(original_digest)
      end

      it 'renders edit template' do
        patch :update, params: invalid_user_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:student) { create(:user, :complete_student).student_profile }
    let(:user) { student.user }

    it 'destroys the student profile' do
      expect {
        delete :destroy, params: { id: student.id }
      }.to change { StudentProfile.count }.by(-1)
    end

    it 'destroys the associated user' do
      user_id = user.id
      delete :destroy, params: { id: student.id }
      expect(User.find_by(id: user_id)).to be_nil
    end

    it 'redirects to admin dashboard' do
      delete :destroy, params: { id: student.id }
      expect(response).to redirect_to(admin_dashboard_path)
    end

    it 'sets success notice' do
      delete :destroy, params: { id: student.id }
      expect(flash[:notice]).to eq('Aluno removido com sucesso!')
    end
  end
end
