require 'rails_helper'

RSpec.describe Admin::PendingRegistrationsController, type: :controller do
  after do
    Current.reset
  end

  let(:admin) { create(:user, :admin) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:require_authentication).and_return(true)
  end

  describe 'POST #reject' do
    let!(:pending_registration) { create(:pending_registration, :pending) }

    context 'quando o admin rejeita um cadastro' do
      it 'atualiza o status para rejected' do
        post :reject, params: { id: pending_registration.id }
        pending_registration.reload
        expect(pending_registration.status).to eq('rejected')
      end

      it 'define rejected_at com a data atual' do
        post :reject, params: { id: pending_registration.id }
        pending_registration.reload
        expect(pending_registration.rejected_at).to be_within(5.seconds).of(Time.current)
      end

      it 'associa o admin que rejeitou' do
        post :reject, params: { id: pending_registration.id }
        pending_registration.reload
        expect(pending_registration.rejected_by).to eq(admin)
      end

      it 'exibe mensagem de sucesso' do
        post :reject, params: { id: pending_registration.id }
        expect(flash[:notice]).to eq('Cadastro rejeitado e aluno notificado.')
      end

      it 'redireciona para admin_dashboard_path' do
        post :reject, params: { id: pending_registration.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end

      context 'quando acessado do dashboard' do
        before do
          request.env['HTTP_REFERER'] = admin_dashboard_url
        end

        it 'volta para o dashboard após rejeitar' do
          post :reject, params: { id: pending_registration.id }
          expect(response).to redirect_to(admin_dashboard_path)
        end
      end
    end

    context 'quando o cadastro não existe' do
      it 'retorna 404' do
        post :reject, params: { id: 99999 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'quando há erro ao rejeitar' do
      before do
        allow_any_instance_of(PendingRegistration).to receive(:reject!).and_return(false)
      end

      it 'exibe mensagem de erro' do
        post :reject, params: { id: pending_registration.id }
        expect(flash[:alert]).to eq('Erro ao rejeitar cadastro.')
      end

      it 'redireciona para admin_dashboard_path mesmo com erro' do
        post :reject, params: { id: pending_registration.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end
  end

  describe 'POST #approve' do
    let!(:pending_registration) { create(:pending_registration, :pending) }

    context 'quando o admin aprova um cadastro' do
      it 'atualiza o status para approved' do
        post :approve, params: { id: pending_registration.id }
        pending_registration.reload
        expect(pending_registration.status).to eq('approved')
      end

      it 'cria um novo usuário com o email da registration' do
        expect {
          post :approve, params: { id: pending_registration.id }
        }.to change(User, :count).by(1)

        created_user = User.find_by(email_address: pending_registration.email)
        expect(created_user).to be_present
        expect(created_user.role).to eq('student')
      end

      it 'cria um perfil de aluno para o usuário' do
        post :approve, params: { id: pending_registration.id }

        created_user = User.find_by(email_address: pending_registration.email)
        expect(created_user.student_profile).to be_present
        expect(created_user.student_profile.name).to eq(pending_registration.name)
      end

      it 'redireciona para admin_dashboard_path' do
        post :approve, params: { id: pending_registration.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context 'quando há erro ao aprovar' do
      before do
        allow_any_instance_of(PendingRegistration).to receive(:approve!).and_return(false)
      end

      it 'redireciona para admin_dashboard_path mesmo com erro' do
        post :approve, params: { id: pending_registration.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end
  end

  describe 'POST #reset' do
    let!(:rejected_registration) { create(:pending_registration, :rejected) }

    context 'quando o admin reseta um cadastro rejeitado' do
      it 'atualiza o status para pending' do
        post :reset, params: { id: rejected_registration.id }
        rejected_registration.reload
        expect(rejected_registration.status).to eq('pending')
      end

      it 'limpa o rejected_at' do
        post :reset, params: { id: rejected_registration.id }
        rejected_registration.reload
        expect(rejected_registration.rejected_at).to be_nil
      end

      it 'limpa o rejected_by' do
        post :reset, params: { id: rejected_registration.id }
        rejected_registration.reload
        expect(rejected_registration.rejected_by).to be_nil
      end

      it 'exibe mensagem de sucesso' do
        post :reset, params: { id: rejected_registration.id }
        expect(flash[:notice]).to eq('Cadastro devolvido para análise.')
      end

      it 'redireciona para admin_dashboard_path' do
        post :reset, params: { id: rejected_registration.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context 'quando reseta um cadastro aprovado' do
      let!(:approved_registration) { create(:pending_registration, :approved) }

      it 'também limpa approved_at e approved_by' do
        post :reset, params: { id: approved_registration.id }
        approved_registration.reload
        expect(approved_registration.status).to eq('pending')
        expect(approved_registration.approved_at).to be_nil
        expect(approved_registration.approved_by).to be_nil
      end
    end

    context 'quando há erro ao resetar' do
      before do
        allow_any_instance_of(PendingRegistration).to receive(:reset_to_pending!).and_return(false)
      end

      it 'exibe mensagem de erro' do
        post :reset, params: { id: rejected_registration.id }
        expect(flash[:alert]).to eq('Erro ao resetar cadastro.')
      end

      it 'redireciona para admin_dashboard_path mesmo com erro' do
        post :reset, params: { id: rejected_registration.id }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:pending_registration) { create(:pending_registration, :pending) }

    it 'remove o cadastro' do
      expect {
        delete :destroy, params: { id: pending_registration.id }
      }.to change(PendingRegistration, :count).by(-1)
    end

    it 'exibe mensagem de sucesso' do
      delete :destroy, params: { id: pending_registration.id }
      expect(flash[:notice]).to eq('Cadastro removido.')
    end

    it 'redireciona para admin_dashboard_path' do
      delete :destroy, params: { id: pending_registration.id }
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe 'GET #index' do
    it 'redireciona para o dashboard' do
      get :index
      expect(response).to redirect_to(admin_dashboard_path)
    end

    it 'não tenta renderizar view inexistente' do
      get :index
      expect(response).to have_http_status(:redirect)
    end
  end
end
