require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#temporary_password' do
    let(:user) { create(:user, email_address: 'aluno@example.com') }
    let(:mail) { described_class.temporary_password(user, 'senha-temporaria') }

    it 'addresses the approved user' do
      expect(mail.to).to eq([ 'aluno@example.com' ])
      expect(mail.subject).to be_present
    end

    it 'carries the temporary password, which is the only copy the user gets' do
      expect(mail.body.encoded).to include('senha-temporaria')
    end

    it 'links to the login page on the configured domain' do
      expect(mail.body.encoded).to include(ENV.fetch('DOMAIN', 'example.com'))
    end

    it 'sends from the configured sender' do
      expect(mail.from).to eq([ ENV.fetch('MAILER_FROM', 'noreply@example.com') ])
    end
  end
end
