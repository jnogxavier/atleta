require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    describe '.expired' do
      it 'returns only expired sessions' do
        expired_session = create(:session, :expired)
        active_session = create(:session, :active)

        expect(Session.expired).to include(expired_session)
        expect(Session.expired).not_to include(active_session)
      end

      it 'returns sessions that expired in the past' do
        past_session = create(:session, expires_at: 1.hour.ago)
        future_session = create(:session, expires_at: 1.hour.from_now)

        expect(Session.expired).to include(past_session)
        expect(Session.expired).not_to include(future_session)
      end

      it 'does not include sessions expiring in the future' do
        future_session = create(:session, expires_at: 1.hour.from_now)
        expect(Session.expired).not_to include(future_session)
      end
    end

    describe '.active' do
      it 'returns only active sessions' do
        expired_session = create(:session, :expired)
        active_session = create(:session, :active)

        expect(Session.active).to include(active_session)
        expect(Session.active).not_to include(expired_session)
      end

      it 'includes sessions expiring in the future' do
        future_session = create(:session, expires_at: 1.hour.from_now)
        past_session = create(:session, expires_at: 1.hour.ago)

        expect(Session.active).to include(future_session)
        expect(Session.active).not_to include(past_session)
      end

      it 'includes sessions expiring soon' do
        soon_session = create(:session, expires_at: 1.hour.from_now)
        expect(Session.active).to include(soon_session)
      end
    end
  end

  describe 'callbacks' do
    describe '#set_expiration' do
      it 'sets expires_at to 30 days from now on creation' do
        session = create(:session)
        expected_expiration = 30.days.from_now

        expect(session.expires_at).to be_within(5.seconds).of(expected_expiration)
      end

      it 'does not override manually set expires_at' do
        custom_expiration = 60.days.from_now
        session = create(:session, expires_at: custom_expiration)

        expect(session.expires_at).to be_within(1.second).of(custom_expiration)
      end

      it 'is only called on create, not update' do
        session = create(:session)
        original_expiration = session.expires_at

        session.update(user: create(:user))
        expect(session.reload.expires_at).to eq(original_expiration)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      session = build(:session)
      expect(session).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:session, :expired)).to be_valid
      expect(build(:session, :active)).to be_valid
      expect(build(:session, :expiring_soon)).to be_valid
    end

    it 'creates an expired session with the expired trait' do
      session = create(:session, :expired)
      expect(session.expires_at).to be < Time.current
    end

    it 'creates an active session with the active trait' do
      session = create(:session, :active)
      expect(session.expires_at).to be > Time.current
    end

    it 'creates a session expiring soon with the expiring_soon trait' do
      session = create(:session, :expiring_soon)
      expect(session.expires_at).to be_between(Time.current, 2.days.from_now)
    end
  end

  describe 'user association' do
    it 'belongs to a user' do
      user = create(:user)
      session = create(:session, user: user)

      expect(session.user).to eq(user)
    end

    it 'is destroyed when user is destroyed' do
      user = create(:user)
      session = create(:session, user: user)

      expect { user.destroy }.to change { Session.count }.by(-1)
    end

    it 'allows multiple sessions for the same user' do
      user = create(:user)
      session1 = create(:session, user: user)
      session2 = create(:session, user: user)

      expect(user.sessions.count).to eq(2)
      expect(user.sessions).to include(session1, session2)
    end
  end

  describe 'expiration logic' do
    it 'can check if a session is expired' do
      expired_session = create(:session, expires_at: 1.day.ago)
      active_session = create(:session, expires_at: 1.day.from_now)

      expect(expired_session.expires_at).to be < Time.current
      expect(active_session.expires_at).to be > Time.current
    end

    it 'handles sessions with different expiration times' do
      session_1_day = create(:session, expires_at: 1.day.from_now)
      session_30_days = create(:session, expires_at: 30.days.from_now)
      session_60_days = create(:session, expires_at: 60.days.from_now)

      expect(Session.active.count).to eq(3)
      expect(Session.active).to include(session_1_day, session_30_days, session_60_days)
    end
  end

  describe 'data integrity' do
    it 'stores expires_at as datetime' do
      session = create(:session)
      expect(session.expires_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'can update expires_at' do
      session = create(:session)
      new_expiration = 60.days.from_now
      session.update(expires_at: new_expiration)

      expect(session.reload.expires_at).to be_within(1.second).of(new_expiration)
    end

    it 'maintains expiration after reload' do
      session = create(:session, expires_at: 45.days.from_now)
      original_expiration = session.expires_at

      session.reload
      expect(session.expires_at).to be_within(1.second).of(original_expiration)
    end
  end
end
