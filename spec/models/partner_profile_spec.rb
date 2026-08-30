require 'rails_helper'

RSpec.describe PartnerProfile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    describe 'partner_id uniqueness' do
      it 'allows nil partner_id' do
        profile = build(:partner_profile, partner_id: nil)
        expect(profile).to be_valid
      end

      it 'allows blank partner_id' do
        profile = build(:partner_profile, partner_id: '')
        expect(profile).to be_valid
      end

      it 'requires unique partner_id when set' do
        create(:partner_profile, partner_id: 'PARTNER123')
        duplicate = build(:partner_profile, partner_id: 'PARTNER123')

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:partner_id]).to be_present
      end

      it 'allows multiple nil partner_ids' do
        create(:partner_profile, partner_id: nil)
        duplicate = build(:partner_profile, partner_id: nil)

        expect(duplicate).to be_valid
      end

      it 'validates uniqueness case-sensitively' do
        create(:partner_profile, partner_id: 'partner123')
        duplicate = build(:partner_profile, partner_id: 'PARTNER123')

        expect(duplicate).to be_valid
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 'active', inactive: 'inactive', suspended: 'suspended').backed_by_column_of_type(:string) }

    it 'has active status by default' do
      profile = create(:partner_profile)
      expect(profile.status).to eq('active')
      expect(profile.active?).to be true
    end

    it 'can be set to inactive' do
      profile = create(:partner_profile, :inactive)
      expect(profile.inactive?).to be true
    end

    it 'can be set to suspended' do
      profile = create(:partner_profile, :suspended)
      expect(profile.suspended?).to be true
    end

    it 'can change status from active to inactive' do
      profile = create(:partner_profile, status: :active)
      profile.update(status: :inactive)

      expect(profile.inactive?).to be true
    end

    it 'can change status from inactive to active' do
      profile = create(:partner_profile, :inactive)
      profile.update(status: :active)

      expect(profile.active?).to be true
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      profile = build(:partner_profile)
      expect(profile).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:partner_profile, :inactive)).to be_valid
      expect(build(:partner_profile, :suspended)).to be_valid
    end

    it 'creates unique names with sequence' do
      profile1 = create(:partner_profile)
      profile2 = create(:partner_profile)

      expect(profile1.name).not_to eq(profile2.name)
    end

    it 'associates with a partner user by default' do
      profile = create(:partner_profile)
      expect(profile.user.partner?).to be true
    end
  end

  describe 'user association' do
    it 'belongs to a user' do
      user = create(:user, :partner)
      profile = create(:partner_profile, user: user)

      expect(profile.user).to eq(user)
    end

    it 'is destroyed when user is destroyed' do
      user = create(:user, :partner)
      profile = create(:partner_profile, user: user)

      expect { user.destroy }.to change { PartnerProfile.count }.by(-1)
    end
  end

  describe 'partner_id' do
    it 'can be set to a custom value' do
      profile = create(:partner_profile, partner_id: 'CUSTOM001')
      expect(profile.partner_id).to eq('CUSTOM001')
    end

    it 'can be updated' do
      profile = create(:partner_profile, partner_id: 'OLD001')
      profile.update(partner_id: 'NEW001')

      expect(profile.partner_id).to eq('NEW001')
    end

    it 'can be set to nil' do
      profile = create(:partner_profile, partner_id: 'TEMP001')
      profile.update(partner_id: nil)

      expect(profile.partner_id).to be_nil
    end
  end

  describe 'status transitions' do
    it 'tracks status changes' do
      profile = create(:partner_profile, status: :active)

      expect {
        profile.update(status: :suspended)
      }.to change { profile.status }.from('active').to('suspended')
    end

    it 'allows multiple status transitions' do
      profile = create(:partner_profile, status: :active)

      profile.update(status: :inactive)
      expect(profile.inactive?).to be true

      profile.update(status: :suspended)
      expect(profile.suspended?).to be true

      profile.update(status: :active)
      expect(profile.active?).to be true
    end
  end

  describe 'query methods' do
    it 'can query by status' do
      active_profile = create(:partner_profile, status: :active)
      inactive_profile = create(:partner_profile, :inactive)
      suspended_profile = create(:partner_profile, :suspended)

      expect(PartnerProfile.where(status: :active)).to include(active_profile)
      expect(PartnerProfile.where(status: :inactive)).to include(inactive_profile)
      expect(PartnerProfile.where(status: :suspended)).to include(suspended_profile)
    end
  end
end
