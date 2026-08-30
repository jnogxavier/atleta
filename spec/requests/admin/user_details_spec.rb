require 'rails_helper'

RSpec.describe 'Admin User Details', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :student) }

  before do
    post session_path, params: { email_address: admin.email_address, password: admin.password }
  end

  describe 'GET /admin/users/:id' do
    it 'displays user details page' do
      get admin_user_path(student)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Detalhes do Usuário')
      expect(response.body).to include(student.email_address)
    end

    it 'shows account information' do
      get admin_user_path(student)

      expect(response.body).to include('Informações da Conta')
      expect(response.body).to include(student.email_address)
      expect(response.body).to include('Aluno')
    end

    it 'shows student profile section when user is student with profile' do
      profile = create(:student_profile, user: student, plan: 'premium', expires_at: 30.days.from_now)

      get admin_user_path(student)

      expect(response.body).to include('Perfil do Aluno')
      # StudentProfile#name is mirrored from the user by a before_save callback,
      # so the rendered name is the user's, not whatever the factory sequenced.
      expect(response.body).to include(student.name)
      expect(response.body).to include('Premium')
      expect(response.body).to include(I18n.l(profile.expires_at.to_date))
    end

    it 'shows partner profile section when user is partner with profile' do
      partner = create(:user, :partner)
      create(:partner_profile, user: partner, profession: 'Fisioterapeuta', specialty: 'Ortopedia')

      get admin_user_path(partner)

      expect(response.body).to include('Perfil do Parceiro')
      expect(response.body).to include('Fisioterapeuta')
      expect(response.body).to include('Ortopedia')
    end

    it 'shows deactivation history when user was deactivated' do
      other_admin = create(:user, :admin)
      student.update(
        deactivated_at: 1.day.ago,
        deactivated_by_id: other_admin.id,
        deactivation_reason: 'Payment overdue'
      )

      get admin_user_path(student)

      expect(response.body).to include('Histórico de Status')
      expect(response.body).to include('Desativação')
      expect(response.body).to include('Payment overdue')
      expect(response.body).to include(other_admin.email_address)
    end

    it 'shows activation history when user was activated' do
      student.update(
        activated_at: 1.hour.ago,
        activated_by_id: admin.id,
        activation_reason: 'Payment received'
      )

      get admin_user_path(student)

      expect(response.body).to include('Histórico de Status')
      expect(response.body).to include('Ativação')
      expect(response.body).to include('Payment received')
    end

    it 'shows current account status as active' do
      get admin_user_path(student)

      expect(response.body).to include('Status Atual')
      expect(response.body).to include('Ativa')
    end

    it 'shows current account status as deactivated when user is deactivated' do
      student.update(deactivated_at: Time.current)

      get admin_user_path(student)

      expect(response.body).to include('Status Atual')
      expect(response.body).to include('Desativada')
    end

    it 'shows quick action to edit user' do
      get admin_user_path(student)

      expect(response.body).to include('Ações Rápidas')
      expect(response.body).to include('Editar Usuário')
      expect(response.body).to include(edit_admin_user_path(student))
    end

    it 'shows deactivate button when user is active' do
      get admin_user_path(student)

      expect(response.body).to include('Desativar Conta')
    end

    it 'shows activate button when user is deactivated' do
      student.update(deactivated_at: Time.current)

      get admin_user_path(student)

      expect(response.body).to include('Ativar Conta')
    end

    it 'does not show deactivate/activate buttons for current admin' do
      get admin_user_path(admin)

      expect(response.body).not_to include('Desativar Conta')
      expect(response.body).not_to include('Ativar Conta')
    end

    it 'includes back to dashboard link' do
      get admin_user_path(student)

      expect(response.body).to include('Voltar para Dashboard')
      expect(response.body).to include(admin_dashboard_path)
    end

    it 'shows user ID in header' do
      get admin_user_path(student)

      expect(response.body).to include("ID: ##{student.id}")
    end

    it 'shows created and updated timestamps' do
      get admin_user_path(student)

      expect(response.body).to include('Criado em')
      expect(response.body).to include('Última atualização')
    end
  end

  describe 'authorization' do
    context 'when not authenticated' do
      before { delete logout_path }

      it 'redirects to login' do
        get admin_user_path(student)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context 'when authenticated as non-admin' do
      it 'redirects non-admin users to the root path' do
        sign_in(create(:user, :student))

        get admin_user_path(student)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('flash.alerts.access_restricted_admin'))
      end
    end
  end

  describe 'profile details' do
    it 'falls back to placeholders when optional student fields are blank' do
      create(:student_profile, user: student, plan: nil, expires_at: nil)

      get admin_user_path(student)

      expect(response.body).to include('Perfil do Aluno')
      expect(response.body).to include('Não definido')
    end

    it 'falls back to a placeholder when the partner specialty is blank' do
      partner = create(:user, :partner)
      create(:partner_profile, user: partner, profession: 'Fisioterapeuta', specialty: nil)

      get admin_user_path(partner)

      expect(response.body).to include('Perfil do Parceiro')
      expect(response.body).to include('Não definida')
    end
  end

  describe 'status history formatting' do
    it 'formats deactivation date correctly' do
      deactivation_time = Time.zone.parse('2025-01-15 10:30:00')
      student.update(deactivated_at: deactivation_time)

      get admin_user_path(student)

      expect(response.body).to include(I18n.l(deactivation_time, format: :long))
    end

    it 'shows both deactivation and activation history' do
      student.update(
        deactivated_at: 2.days.ago,
        deactivated_by_id: admin.id,
        deactivation_reason: 'First deactivation',
        activated_at: 1.day.ago,
        activated_by_id: admin.id,
        activation_reason: 'Reactivated after payment'
      )

      get admin_user_path(student)

      expect(response.body).to include('First deactivation')
      expect(response.body).to include('Reactivated after payment')
    end
  end
end
