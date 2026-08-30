require 'rails_helper'

RSpec.describe CheckPlanStatusesJob, type: :job do
  let!(:admin) { create(:user, :admin) }

  describe 'expired plans' do
    let!(:profile) { create(:student_profile, expires_at: 3.days.ago) }

    it 'suspends the plan and notifies both the student and the admins' do
      described_class.new.perform

      expect(profile.reload.status).to eq('suspended')
      expect(Notification.where(user: profile.user, notification_type: 'error')).to exist
      expect(Notification.where(user: admin, notification_type: 'warning')).to exist
    end

    it 'leaves already-suspended plans alone' do
      profile.update!(status: 'suspended')

      expect { described_class.new.perform }
        .not_to change { Notification.where(user: admin).count }
    end

    # The job runs daily on a schedule, so a second pass must not re-notify.
    it 'does not notify twice when it runs again the same day' do
      described_class.new.perform

      expect { described_class.new.perform }
        .not_to change { Notification.count }
    end
  end

  describe 'plans with no expiry' do
    let!(:profile) { create(:student_profile, expires_at: nil) }

    it 'leaves an open-ended plan untouched' do
      described_class.new.perform

      expect(profile.reload.status).to eq('active')
      expect(Notification.count).to eq(0)
    end
  end

  describe 'expiring plans' do
    let!(:profile) { create(:student_profile, expires_at: 5.days.from_now) }

    it 'notifies the student and the admins without suspending' do
      described_class.new.perform

      expect(profile.reload.status).to eq('active')
      expect(Notification.where(user: profile.user, notification_type: 'expiration')).to exist
      expect(Notification.where(user: admin, notification_type: 'expiration')).to exist
    end

    it 'ignores plans expiring beyond the 15 day notice window' do
      profile.update!(expires_at: 40.days.from_now)

      described_class.new.perform

      expect(Notification.count).to eq(0)
    end
  end
end
