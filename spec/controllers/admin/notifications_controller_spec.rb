require 'rails_helper'

RSpec.describe Admin::NotificationsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user, :complete_student) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:require_authentication).and_return(true)
  end

  after do
    Current.reset
  end

  describe 'POST #bulk_send' do
    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:require_authentication).and_call_original
      end

      it 'requires authentication' do
        post :bulk_send, params: { recipient_type: 'all', title: 'Test', message: 'Test message' }
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not an admin' do
      before do
        allow(controller).to receive(:current_user).and_return(student)
      end

      it 'denies access and redirects to root' do
        post :bulk_send, params: { recipient_type: 'all', title: 'Test', message: 'Test message' }
        expect(response).to redirect_to(root_path)
      end

      it 'sets alert message' do
        post :bulk_send, params: { recipient_type: 'all', title: 'Test', message: 'Test message' }
        expect(flash[:alert]).to eq('You must be an admin to access this page.')
      end
    end

    context 'when user is an admin' do
      let!(:student1) { create(:user, :complete_student) }
      let!(:student2) { create(:user, :complete_student) }

      context 'sending to all students' do
        let(:params) do
          {
            recipient_type: 'all',
            notification_type: 'info',
            title: 'Important Update',
            message: 'Please check your training schedule',
            action_url: '/trainings'
          }
        end

        it 'creates notifications for all students' do
          expect {
            post :bulk_send, params: params
          }.to change { Notification.count }.by_at_least(2)
        end

        it 'redirects to admin dashboard' do
          post :bulk_send, params: params
          expect(response).to redirect_to(admin_dashboard_path)
        end

        it 'sets success notice with count' do
          post :bulk_send, params: params
          expect(flash[:notice]).to match(/Notificação enviada com sucesso/)
          expect(flash[:notice]).to match(/\d+ alunos?/)
        end

        it 'creates notifications with correct attributes' do
          post :bulk_send, params: params
          notification = Notification.last
          expect(notification.title).to eq('Important Update')
          expect(notification.message).to eq('Please check your training schedule')
          expect(notification.notification_type).to eq('info')
          expect(notification.action_url).to eq('/trainings')
        end
      end

      context 'sending to active students only' do
        let!(:active_student) { create(:user, :complete_student) }
        let!(:inactive_student) { create(:user, :complete_student) }

        before do
          active_student.student_profile.update(status: 'active')
          inactive_student.student_profile.update(status: 'inactive')
        end

        let(:params) do
          {
            recipient_type: 'active',
            notification_type: 'success',
            title: 'Active Members Only',
            message: 'Thank you for being active'
          }
        end

        it 'creates notifications only for active students' do
          active_count = StudentProfile.active.count
          expect {
            post :bulk_send, params: params
          }.to change { Notification.count }.by(active_count)
        end
      end

      context 'sending to inactive students only' do
        let!(:active_student) { create(:user, :complete_student) }
        let!(:inactive_student) { create(:user, :complete_student) }

        before do
          active_student.student_profile.update(status: 'active')
          inactive_student.student_profile.update(status: 'inactive')
        end

        let(:params) do
          {
            recipient_type: 'inactive',
            notification_type: 'warning',
            title: 'We Miss You',
            message: 'Come back to training'
          }
        end

        it 'creates notifications only for inactive students' do
          inactive_count = StudentProfile.inactive.count
          expect {
            post :bulk_send, params: params
          }.to change { Notification.count }.by(inactive_count)
        end
      end

      context 'sending to expiring soon students' do
        let!(:expiring_student) { create(:user, :complete_student) }
        let!(:non_expiring_student) { create(:user, :complete_student) }

        before do
          expiring_student.student_profile.update(expires_at: 10.days.from_now)
          non_expiring_student.student_profile.update(expires_at: 30.days.from_now)
        end

        let(:params) do
          {
            recipient_type: 'expiring_soon',
            notification_type: 'expiration',
            title: 'Plan Expiring Soon',
            message: 'Your plan expires in 10 days'
          }
        end

        it 'creates notifications for students expiring within 15 days' do
          expect {
            post :bulk_send, params: params
          }.to change { Notification.count }.by_at_least(1)
        end
      end

      context 'with action_url parameter' do
        let(:params) do
          {
            recipient_type: 'all',
            notification_type: 'training',
            title: 'New Training',
            message: 'Check your new training',
            action_url: '/student/trainings'
          }
        end

        it 'includes action_url in notifications' do
          post :bulk_send, params: params
          notification = Notification.last
          expect(notification.action_url).to eq('/student/trainings')
        end
      end

      context 'without action_url parameter' do
        let(:params) do
          {
            recipient_type: 'all',
            notification_type: 'info',
            title: 'General Info',
            message: 'Just FYI',
            action_url: ''
          }
        end

        it 'creates notifications without action_url' do
          post :bulk_send, params: params
          notification = Notification.last
          expect(notification.action_url).to be_nil
        end
      end
    end
  end

  describe 'POST #mark_as_read' do
    let!(:notification) { create(:notification, user: admin, read_at: nil) }

    it 'marks notification as read' do
      post :mark_as_read, params: { id: notification.id }
      notification.reload
      expect(notification.read_at).to be_present
    end

    it 'redirects back to previous page' do
      post :mark_as_read, params: { id: notification.id }
      expect(response).to have_http_status(:redirect)
    end

    context 'when notification belongs to different user' do
      let(:other_user) { create(:user, :complete_student) }
      let!(:other_notification) { create(:notification, user: other_user) }

      it 'returns error when notification belongs to different user' do
        post :mark_as_read, params: { id: other_notification.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #mark_all_as_read' do
    let!(:unread_notification1) { create(:notification, user: admin, read_at: nil) }
    let!(:unread_notification2) { create(:notification, user: admin, read_at: nil) }
    let!(:read_notification) { create(:notification, :read, user: admin) }

    it 'marks all unread notifications as read' do
      expect {
        post :mark_all_as_read
      }.to change { admin.notifications.unread.count }.to(0)
    end

    it 'does not affect already read notifications' do
      expect {
        post :mark_all_as_read
      }.not_to change { read_notification.reload.read_at }
    end

    it 'redirects back to previous page' do
      post :mark_all_as_read
      expect(response).to have_http_status(:redirect)
    end

    it 'sets success notice' do
      post :mark_all_as_read
      expect(flash[:notice]).to eq('Todas as notificações foram marcadas como lidas')
    end

    context 'when user has notifications from other users' do
      let(:other_user) { create(:user, :complete_student) }
      let!(:other_notification) { create(:notification, user: other_user, read_at: nil) }

      it 'only marks current user notifications as read' do
        post :mark_all_as_read
        expect(admin.notifications.unread.count).to eq(0)
        expect(other_user.notifications.unread.count).to eq(1)
      end
    end
  end
end
