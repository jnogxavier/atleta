require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_one(:student_profile).dependent(:destroy) }
    it { should have_one(:partner_profile).dependent(:destroy) }
    it { should have_one(:anamnese).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:evaluation_media).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email_address) }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should allow_value('user@example.com').for(:email_address) }
    it { should_not allow_value('invalid_email').for(:email_address) }

    context 'when user is complete' do
      subject { build(:user, registration_status: :complete) }

      it 'requires password to be at least 8 characters' do
        user = build(:user, registration_status: :complete, password: 'short')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('deve ter no mínimo 8 caracteres')
      end

      it 'requires terms to be accepted' do
        user = build(:user, registration_status: :complete, terms_accepted: false)
        expect(user).not_to be_valid
        expect(user.errors[:terms_accepted]).to include('deve ser aceito')
      end
    end

    context 'when user is draft' do
      subject { build(:user, :draft) }

      it 'does not require password' do
        user = build(:user, :draft, password: nil)
        expect(user).to be_valid
      end

      it 'does not require terms acceptance' do
        user = build(:user, :draft, terms_accepted: false)
        expect(user).to be_valid
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(admin: 0, student: 1, partner: 2).with_default(:student) }
    it { should define_enum_for(:registration_status).with_values(draft: 0, complete: 1).with_default(:draft) }
  end

  describe 'email normalization' do
    it 'normalizes email to lowercase and strips whitespace' do
      user = create(:user, email_address: '  USER@EXAMPLE.COM  ')
      expect(user.email_address).to eq('user@example.com')
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end

    it 'returns false for non-admin users' do
      user = create(:user, :student)
      expect(user.admin?).to be false
    end
  end

  describe '#student?' do
    it 'returns true for student users' do
      user = create(:user, :student)
      expect(user.student?).to be true
    end

    it 'returns false for non-student users' do
      user = create(:user, :admin)
      expect(user.student?).to be false
    end
  end

  describe '#partner?' do
    it 'returns true for partner users' do
      user = create(:user, :partner)
      expect(user.partner?).to be true
    end

    it 'returns false for non-partner users' do
      user = create(:user, :student)
      expect(user.partner?).to be false
    end
  end

  describe '#display_role' do
    it 'returns titleized role' do
      user = create(:user, :student)
      expect(user.display_role).to eq('Student')
    end
  end

  describe '#profile' do
    it 'returns student_profile for student users' do
      user = create(:user, :student)
      profile = create(:student_profile, user: user)
      expect(user.profile).to eq(profile)
    end

    it 'returns partner_profile for partner users' do
      user = create(:user, :partner)
      profile = create(:partner_profile, user: user)
      expect(user.profile).to eq(profile)
    end

    it 'returns nil for admin users' do
      user = create(:user, :admin)
      expect(user.profile).to be_nil
    end
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for anamnese' do
      user = create(:user)
      expect {
        user.update(anamnese_attributes: attributes_for(:anamnese))
      }.to change { user.anamnese }.from(nil)
    end

    it 'accepts nested attributes for student_profile' do
      user = create(:user, :student)
      expect {
        user.update(student_profile_attributes: { name: 'Test Student' })
      }.to change { user.student_profile }.from(nil)
    end

    it 'accepts nested attributes for partner_profile' do
      user = create(:user, :partner)
      expect {
        user.update(partner_profile_attributes: { name: 'Test Partner' })
      }.to change { user.partner_profile }.from(nil)
    end
  end
end
