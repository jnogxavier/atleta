require 'rails_helper'

RSpec.describe PendingRegistration, type: :model do
  describe 'associations' do
    it { should belong_to(:approved_by).class_name('User').optional }
    it { should belong_to(:rejected_by).class_name('User').optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone) }

    describe 'email validation' do
      subject { build(:pending_registration) }

      it { should validate_uniqueness_of(:email) }
      it { should allow_value('user@example.com').for(:email) }
      it { should allow_value('test.user@domain.co.uk').for(:email) }
      it { should_not allow_value('invalid_email').for(:email) }
      it { should_not allow_value('@example.com').for(:email) }

      it 'rejects duplicate emails' do
        create(:pending_registration, email: 'duplicate@example.com')
        duplicate = build(:pending_registration, email: 'duplicate@example.com')

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:email]).to be_present
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 'pending', approved: 'approved', rejected: 'rejected').backed_by_column_of_type(:string) }

    it 'has pending status by default' do
      registration = create(:pending_registration)
      expect(registration.status).to eq('pending')
      expect(registration.pending?).to be true
    end

    it 'can be set to approved' do
      registration = create(:pending_registration, :approved)
      expect(registration.approved?).to be true
    end

    it 'can be set to rejected' do
      registration = create(:pending_registration, :rejected)
      expect(registration.rejected?).to be true
    end
  end

  describe 'scopes' do
    describe '.pending_only' do
      it 'returns only pending registrations' do
        pending_reg = create(:pending_registration, status: :pending)
        approved_reg = create(:pending_registration, :approved)
        rejected_reg = create(:pending_registration, :rejected)

        expect(PendingRegistration.pending_only).to include(pending_reg)
        expect(PendingRegistration.pending_only).not_to include(approved_reg)
        expect(PendingRegistration.pending_only).not_to include(rejected_reg)
      end
    end

    describe '.recent' do
      it 'orders by created_at descending' do
        old_reg = create(:pending_registration, created_at: 2.days.ago)
        new_reg = create(:pending_registration, created_at: 1.day.ago)
        newest_reg = create(:pending_registration, created_at: Time.current)

        expect(PendingRegistration.recent.first).to eq(newest_reg)
        expect(PendingRegistration.recent.last).to eq(old_reg)
      end
    end
  end

  describe '#approve!' do
    let(:admin) { create(:user, :admin) }
    let(:registration) { create(:pending_registration) }

    it 'changes status to approved' do
      expect {
        registration.approve!(admin)
      }.to change { registration.status }.from('pending').to('approved')
    end

    it 'sets approved_at timestamp' do
      registration.approve!(admin)
      expect(registration.approved_at).to be_within(5.seconds).of(Time.current)
    end

    it 'sets approved_by to the admin user' do
      registration.approve!(admin)
      expect(registration.approved_by).to eq(admin)
    end

    it 'persists the changes to the database' do
      registration.approve!(admin)
      registration.reload

      expect(registration.approved?).to be true
      expect(registration.approved_by).to eq(admin)
      expect(registration.approved_at).to be_present
    end

    it 'uses a transaction' do
      allow(registration).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      expect {
        registration.approve!(admin) rescue nil
      }.not_to change { registration.reload.status }
    end
  end

  describe '#reject!' do
    let(:admin) { create(:user, :admin) }
    let(:registration) { create(:pending_registration) }

    it 'changes status to rejected' do
      expect {
        registration.reject!(admin)
      }.to change { registration.status }.from('pending').to('rejected')
    end

    it 'sets rejected_at timestamp' do
      registration.reject!(admin)
      expect(registration.rejected_at).to be_within(5.seconds).of(Time.current)
    end

    it 'sets rejected_by to the admin user' do
      registration.reject!(admin)
      expect(registration.rejected_by).to eq(admin)
    end

    it 'accepts optional rejection notes' do
      registration.reject!(admin, 'Incomplete information')
      expect(registration.notes).to eq('Incomplete information')
    end

    it 'keeps existing notes if no rejection notes provided' do
      registration.update(notes: 'Original notes')
      registration.reject!(admin)
      expect(registration.notes).to eq('Original notes')
    end

    it 'overwrites existing notes if rejection notes provided' do
      registration.update(notes: 'Original notes')
      registration.reject!(admin, 'New rejection reason')
      expect(registration.notes).to eq('New rejection reason')
    end

    it 'persists the changes to the database' do
      registration.reject!(admin, 'Test reason')
      registration.reload

      expect(registration.rejected?).to be true
      expect(registration.rejected_by).to eq(admin)
      expect(registration.rejected_at).to be_present
      expect(registration.notes).to eq('Test reason')
    end

    it 'uses a transaction' do
      allow(registration).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      expect {
        registration.reject!(admin) rescue nil
      }.not_to change { registration.reload.status }
    end
  end

  describe '#approved?' do
    it 'returns true when status is approved' do
      registration = create(:pending_registration, :approved)
      expect(registration.approved?).to be true
    end

    it 'returns false when status is pending' do
      registration = create(:pending_registration)
      expect(registration.approved?).to be false
    end

    it 'returns false when status is rejected' do
      registration = create(:pending_registration, :rejected)
      expect(registration.approved?).to be false
    end
  end

  describe '#rejected?' do
    it 'returns true when status is rejected' do
      registration = create(:pending_registration, :rejected)
      expect(registration.rejected?).to be true
    end

    it 'returns false when status is pending' do
      registration = create(:pending_registration)
      expect(registration.rejected?).to be false
    end

    it 'returns false when status is approved' do
      registration = create(:pending_registration, :approved)
      expect(registration.rejected?).to be false
    end
  end

  describe '#pending?' do
    it 'returns true when status is pending' do
      registration = create(:pending_registration)
      expect(registration.pending?).to be true
    end

    it 'returns false when status is approved' do
      registration = create(:pending_registration, :approved)
      expect(registration.pending?).to be false
    end

    it 'returns false when status is rejected' do
      registration = create(:pending_registration, :rejected)
      expect(registration.pending?).to be false
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      registration = build(:pending_registration)
      expect(registration).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:pending_registration, :pending)).to be_valid
      expect(build(:pending_registration, :approved)).to be_valid
      expect(build(:pending_registration, :rejected)).to be_valid
      expect(build(:pending_registration, :with_notes)).to be_valid
    end

    it 'creates unique emails with sequence' do
      reg1 = create(:pending_registration)
      reg2 = create(:pending_registration)

      expect(reg1.email).not_to eq(reg2.email)
    end

    it 'creates unique names with sequence' do
      reg1 = create(:pending_registration)
      reg2 = create(:pending_registration)

      expect(reg1.name).not_to eq(reg2.name)
    end

    it 'creates unique phones with sequence' do
      reg1 = create(:pending_registration)
      reg2 = create(:pending_registration)

      expect(reg1.phone).not_to eq(reg2.phone)
    end
  end

  describe 'workflow' do
    it 'can transition from pending to approved' do
      admin = create(:user, :admin)
      registration = create(:pending_registration)

      registration.approve!(admin)

      expect(registration.pending?).to be false
      expect(registration.approved?).to be true
    end

    it 'can transition from pending to rejected' do
      admin = create(:user, :admin)
      registration = create(:pending_registration)

      registration.reject!(admin)

      expect(registration.pending?).to be false
      expect(registration.rejected?).to be true
    end

    it 'tracks different admin users for approval and rejection' do
      admin1 = create(:user, :admin, email_address: 'admin1@example.com')
      admin2 = create(:user, :admin, email_address: 'admin2@example.com')

      approved_reg = create(:pending_registration, email: 'approved@example.com')
      rejected_reg = create(:pending_registration, email: 'rejected@example.com')

      approved_reg.approve!(admin1)
      rejected_reg.reject!(admin2)

      expect(approved_reg.approved_by).to eq(admin1)
      expect(rejected_reg.rejected_by).to eq(admin2)
    end
  end

  describe 'data integrity' do
    it 'allows nil for approved_by' do
      registration = create(:pending_registration)
      expect(registration.approved_by).to be_nil
    end

    it 'allows nil for rejected_by' do
      registration = create(:pending_registration)
      expect(registration.rejected_by).to be_nil
    end

    it 'allows notes to be optional' do
      registration = create(:pending_registration, notes: nil)
      expect(registration).to be_valid
    end

    it 'stores all required contact information' do
      registration = create(:pending_registration,
        email: 'test@example.com',
        name: 'Test User',
        phone: '(11) 91234-5678')

      expect(registration.email).to eq('test@example.com')
      expect(registration.name).to eq('Test User')
      expect(registration.phone).to eq('(11) 91234-5678')
    end
  end
end
