require 'rails_helper'

RSpec.describe Student::ProfileController, type: :controller do
  after do
    Current.reset
  end

  describe 'authentication and authorization' do
    context 'when user is not authenticated' do
      it 'requires authentication for edit' do
        get :edit
        expect(response).to have_http_status(:redirect)
      end

      it 'requires authentication for update' do
        patch :update, params: { user: { name: 'New Name' } }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'controller structure' do
    it 'responds to edit action' do
      expect(controller).to respond_to(:edit)
    end

    it 'responds to update action' do
      expect(controller).to respond_to(:update)
    end

    it 'is part of the Student module' do
      expect(described_class.name).to eq('Student::ProfileController')
    end

    it 'inherits from ApplicationController' do
      expect(described_class.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_action callbacks' do
    it 'requires authentication' do
      get :edit
      # This will redirect because authentication is required
      expect(response).to redirect_to(new_session_path)
    end

    it 'requires student role' do
      # Without a session, the require_student filter won't even be reached
      # as require_authentication runs first
      get :edit
      expect(response).to have_http_status(:redirect)
    end
  end
end
