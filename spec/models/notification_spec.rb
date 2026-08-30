require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:notification_type) }
  end

  describe 'scopes' do
    let(:user) { create(:user, :complete_student) }
    let!(:unread_notification) { create(:notification, user: user, read_at: nil) }
    let!(:read_notification) { create(:notification, user: user, read_at: 1.day.ago) }

    before do
      # Create with explicit timestamps to ensure proper ordering
      @old_notification = create(:notification, user: user)
      @old_notification.update_column(:created_at, 2.days.ago)

      @recent_notification = create(:notification, user: user)
      @recent_notification.update_column(:created_at, 1.hour.ago)
    end

    describe '.unread' do
      it 'returns only unread notifications' do
        expect(Notification.unread).to include(unread_notification)
        expect(Notification.unread).not_to include(read_notification)
      end
    end

    describe '.read' do
      it 'returns only read notifications' do
        expect(Notification.read).to include(read_notification)
        expect(Notification.read).not_to include(unread_notification)
      end
    end

    describe '.recent' do
      it 'orders notifications by created_at descending' do
        recent_notifications = Notification.recent.where(id: [ @recent_notification.id, @old_notification.id ])
        expect(recent_notifications.first).to eq(@recent_notification)
        expect(recent_notifications.last).to eq(@old_notification)
      end
    end

    describe '.by_type' do
      let!(:info_notification) { create(:notification, :info, user: user) }
      let!(:warning_notification) { create(:notification, :warning, user: user) }

      it 'returns notifications of specified type' do
        expect(Notification.by_type('info')).to include(info_notification)
        expect(Notification.by_type('info')).not_to include(warning_notification)
      end
    end
  end

  describe 'constants' do
    describe 'TYPES' do
      it 'defines all notification types' do
        expect(Notification::TYPES).to eq({
          info: 'info',
          success: 'success',
          warning: 'warning',
          error: 'error',
          expiration: 'expiration',
          training: 'training',
          anamnese: 'anamnese'
        })
      end

      it 'is frozen' do
        expect(Notification::TYPES).to be_frozen
      end
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user, :complete_student) }
    let(:notification) { create(:notification, user: user, read_at: nil) }

    describe '#mark_as_read!' do
      it 'sets read_at to current time' do
        notification.mark_as_read!
        expect(notification.reload.read_at).to be_within(1.second).of(Time.current)
      end

      it 'returns true on success' do
        expect(notification.mark_as_read!).to be_truthy
      end
    end

    describe '#read?' do
      context 'when read_at is present' do
        let(:notification) { create(:notification, user: user, read_at: 1.day.ago) }

        it 'returns true' do
          expect(notification.read?).to be true
        end
      end

      context 'when read_at is nil' do
        let(:notification) { create(:notification, user: user, read_at: nil) }

        it 'returns false' do
          expect(notification.read?).to be false
        end
      end
    end

    describe '#unread?' do
      context 'when read_at is nil' do
        let(:notification) { create(:notification, user: user, read_at: nil) }

        it 'returns true' do
          expect(notification.unread?).to be true
        end
      end

      context 'when read_at is present' do
        let(:notification) { create(:notification, user: user, read_at: 1.day.ago) }

        it 'returns false' do
          expect(notification.unread?).to be false
        end
      end
    end
  end

  describe 'class methods' do
    describe '.create_expiration_notice' do
      let(:user) { create(:user, :complete_student) }
      let(:student_profile) { user.student_profile }

      context 'when expiration date is within 15 days' do
        before do
          student_profile.update(expires_at: 10.days.from_now)
        end

        it 'creates an expiration notification' do
          expect {
            Notification.create_expiration_notice(student_profile)
          }.to change { Notification.count }.by(1)
        end

        it 'sets correct notification attributes' do
          notification = Notification.create_expiration_notice(student_profile)
          expect(notification.user).to eq(user)
          expect(notification.title).to eq('Seu plano está próximo do vencimento')
          expect(notification.message).to include('10 dias')
          expect(notification.notification_type).to eq('expiration')
          expect(notification.action_url).to eq('/student/dashboard')
        end
      end

      context 'when expiration date is today' do
        before do
          student_profile.update(expires_at: Date.current)
        end

        it 'creates an expiration notification' do
          expect {
            Notification.create_expiration_notice(student_profile)
          }.to change { Notification.count }.by(1)
        end

        it 'message shows 0 days' do
          notification = Notification.create_expiration_notice(student_profile)
          expect(notification.message).to include('0 dias')
        end
      end

      context 'when expiration date is more than 15 days away' do
        before do
          student_profile.update(expires_at: 20.days.from_now)
        end

        it 'does not create a notification' do
          expect {
            Notification.create_expiration_notice(student_profile)
          }.not_to change { Notification.count }
        end
      end

      context 'when expiration date has passed' do
        before do
          student_profile.update(expires_at: 1.day.ago)
        end

        it 'does not create a notification' do
          expect {
            Notification.create_expiration_notice(student_profile)
          }.not_to change { Notification.count }
        end
      end

      context 'when expires_at is nil' do
        before do
          student_profile.update(expires_at: nil)
        end

        it 'does not create a notification' do
          expect {
            Notification.create_expiration_notice(student_profile)
          }.not_to change { Notification.count }
        end
      end
    end

    describe '.create_training_assigned' do
      let(:user) { create(:user, :complete_student) }
      let(:training) { create(:training, student_profile: user.student_profile) }

      it 'creates a training notification' do
        expect {
          Notification.create_training_assigned(training)
        }.to change { Notification.count }.by(1)
      end

      it 'sets correct notification attributes' do
        notification = Notification.create_training_assigned(training)
        expect(notification.user).to eq(user)
        expect(notification.title).to eq('Novo treino disponível')
        expect(notification.message).to include(training.name)
        expect(notification.notification_type).to eq('training')
        expect(notification.action_url).to eq('/trainings')
        expect(notification.metadata['training_id']).to eq(training.id)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:notification)).to be_valid
    end

    it 'creates a notification with user association' do
      notification = create(:notification)
      expect(notification.user).to be_present
    end

    describe 'traits' do
      it 'creates read notification' do
        notification = create(:notification, :read)
        expect(notification.read?).to be true
      end

      it 'creates unread notification' do
        notification = create(:notification, :unread)
        expect(notification.unread?).to be true
      end

      it 'creates info notification' do
        notification = create(:notification, :info)
        expect(notification.notification_type).to eq('info')
      end

      it 'creates success notification' do
        notification = create(:notification, :success)
        expect(notification.notification_type).to eq('success')
      end

      it 'creates warning notification' do
        notification = create(:notification, :warning)
        expect(notification.notification_type).to eq('warning')
      end

      it 'creates error notification' do
        notification = create(:notification, :error)
        expect(notification.notification_type).to eq('error')
      end

      it 'creates expiration notification' do
        notification = create(:notification, :expiration)
        expect(notification.notification_type).to eq('expiration')
        expect(notification.title).to eq('Seu plano está próximo do vencimento')
      end

      it 'creates training notification' do
        notification = create(:notification, :training)
        expect(notification.notification_type).to eq('training')
        expect(notification.title).to eq('Novo treino disponível')
      end

      it 'creates anamnese notification' do
        notification = create(:notification, :anamnese)
        expect(notification.notification_type).to eq('anamnese')
        expect(notification.title).to eq('Atualize sua anamnese')
      end
    end
  end
end
