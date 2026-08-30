require 'rails_helper'

RSpec.describe Student::EvaluationMediaController, type: :controller do
  after do
    Current.reset
  end

  describe 'GET #new' do
    context 'when user is not authenticated' do
      it 'requires authentication' do
        get :new
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not authenticated' do
      it 'requires authentication' do
        post :create, params: { evaluation_medium: { category: 'frente' } }
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to login' do
        post :create, params: { evaluation_medium: { category: 'frente' } }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'controller structure' do
    it 'responds to new action' do
      expect(controller).to respond_to(:new)
    end

    it 'responds to create action' do
      expect(controller).to respond_to(:create)
    end

    it 'is part of the Student module' do
      expect(described_class.name).to eq('Student::EvaluationMediaController')
    end

    it 'inherits from ApplicationController' do
      expect(described_class.superclass).to eq(ApplicationController)
    end

    it 'includes Authentication concern' do
      expect(described_class.included_modules).to include(Authentication)
    end
  end

  describe 'before_action callbacks' do
    it 'requires authentication for new' do
      get :new
      expect(response).to redirect_to(new_session_path)
    end

    it 'requires authentication for create' do
      post :create, params: { evaluation_medium: { category: 'frente' } }
      expect(response).to redirect_to(new_session_path)
    end
  end
end
