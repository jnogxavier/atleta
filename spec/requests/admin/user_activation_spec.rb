require 'rails_helper'

RSpec.describe 'Admin User Activation', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :student) }

  before do
    # Simulate login by setting session
    post session_path, params: { email_address: admin.email_address, password: admin.password }
  end

  describe 'PATCH /admin/users/:id/deactivate' do
    context 'when deactivating another user' do
      it 'deactivates the user with reason' do
        expect(student.deactivated_at).to be_nil

        patch deactivate_admin_user_path(student), params: { reason: 'Payment overdue' }

        expect(response).to redirect_to(admin_dashboard_path)
        expect(flash[:notice]).to eq('Usuário desativado com sucesso! Ele não poderá mais fazer login.')

        student.reload
        expect(student.deactivated_at).to be_present
        expect(student.deactivation_reason).to eq('Payment overdue')
        expect(student.deactivated_at).to be_present
        expect(student.deactivated_by_id).to eq(admin.id)
      end

      it 'uses default reason if none provided' do
        patch deactivate_admin_user_path(student), params: { reason: '' }

        student.reload
        expect(student.deactivation_reason).to eq('Sem motivo especificado')
      end

      it 'records deactivation timestamp' do
        freeze_time do
          patch deactivate_admin_user_path(student), params: { reason: 'Test' }

          student.reload
          expect(student.deactivated_at).to eq(Time.current)
        end
      end
    end

    context 'when trying to deactivate own account' do
      it 'prevents deactivation and shows error' do
        patch deactivate_admin_user_path(admin), params: { reason: 'Self deactivation' }

        expect(response).to redirect_to(admin_dashboard_path)
        expect(flash[:alert]).to eq('Você não pode desativar sua própria conta!')

        admin.reload
        expect(admin.deactivated_at).to be_nil
        expect(admin.deactivation_reason).to be_nil
      end
    end
  end

  describe 'PATCH /admin/users/:id/activate' do
    let(:inactive_user) { create(:user, :student, :inactive) }

    it 'activates the user with reason' do
      expect(inactive_user.deactivated_at).to be_present

      patch activate_admin_user_path(inactive_user), params: { reason: 'Payment received' }

      expect(response).to redirect_to(admin_dashboard_path)
      expect(flash[:notice]).to eq('Usuário ativado com sucesso!')

      inactive_user.reload
      expect(inactive_user.deactivated_at).to be_nil
      expect(inactive_user.activation_reason).to eq('Payment received')
      expect(inactive_user.activated_at).to be_present
      expect(inactive_user.activated_by_id).to eq(admin.id)
    end

    it 'uses default reason if none provided' do
      patch activate_admin_user_path(inactive_user), params: { reason: '' }

      inactive_user.reload
      expect(inactive_user.activation_reason).to eq('Sem motivo especificado')
    end

    it 'records activation timestamp' do
      freeze_time do
        patch activate_admin_user_path(inactive_user), params: { reason: 'Test' }

        inactive_user.reload
        expect(inactive_user.activated_at).to eq(Time.current)
      end
    end
  end

  describe 'status tracking' do
    it 'tracks complete deactivation history' do
      patch deactivate_admin_user_path(student), params: { reason: 'Account suspended' }

      student.reload
      expect(student.deactivated_at).to be_present
      expect(student.deactivation_reason).to eq('Account suspended')
      expect(student.deactivated_at).to be_present
      expect(student.deactivated_by_id).to eq(admin.id)
    end

    it 'tracks complete activation history' do
      inactive = create(:user, :student, :inactive)

      patch activate_admin_user_path(inactive), params: { reason: 'Account restored' }

      inactive.reload
      expect(inactive.deactivated_at).to be_nil
      expect(inactive.activation_reason).to eq('Account restored')
      expect(inactive.activated_at).to be_present
      expect(inactive.activated_by_id).to eq(admin.id)
    end

    it 'preserves history across multiple status changes' do
      # Deactivate
      patch deactivate_admin_user_path(student), params: { reason: 'First deactivation' }
      student.reload
      first_deactivation_time = student.deactivated_at

      # Activate
      patch activate_admin_user_path(student), params: { reason: 'First activation' }
      student.reload
      first_activation_time = student.activated_at

      # Verify both timestamps exist
      expect(first_deactivation_time).to be_present
      expect(first_activation_time).to be_present
      expect(first_activation_time).to be > first_deactivation_time
    end
  end

  describe 'authorization' do
    context 'when not authenticated' do
      before { delete logout_path }

      it 'redirects to login for deactivate' do
        patch deactivate_admin_user_path(student), params: { reason: 'Test' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'redirects to login for activate' do
        patch activate_admin_user_path(student), params: { reason: 'Test' }
        expect(response).to redirect_to(new_session_path)
      end
    end

    context 'when authenticated as student' do
      before do
        delete logout_path
        post session_path, params: { email_address: student.email_address, password: student.password }
      end

      it 'forbids deactivation' do
        other_student = create(:user, :student)
        patch deactivate_admin_user_path(other_student), params: { reason: 'Test' }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You must be an admin to access this page.")
      end

      it 'forbids activation' do
        inactive = create(:user, :student, :inactive)
        patch activate_admin_user_path(inactive), params: { reason: 'Test' }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You must be an admin to access this page.")
      end
    end
  end
end
