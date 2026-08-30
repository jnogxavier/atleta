require 'rails_helper'

RSpec.describe PasswordsMailer, type: :mailer do
  describe '#reset' do
    let(:user) { create(:user, email_address: 'aluno@example.com') }

    it 'addresses the requesting user' do
      mail = described_class.reset(user)

      expect(mail.to).to eq([ 'aluno@example.com' ])
      expect(mail.subject).to be_present
    end

    # Building the message has a side effect: it stamps the expiry the reset
    # link is checked against, so a mailer failure would leave a link that
    # never expires.
    it 'gives the reset link a 24 hour expiry' do
      freeze_time do
        expect { described_class.reset(user).message }
          .to change { user.reload.password_expires_at }.from(nil).to(24.hours.from_now)
      end
    end
  end
end
