require 'rails_helper'

describe PhoneValidator do
  # Define a named class for validation tests
  class DummyPhone
    include ActiveModel::Validations
    attr_accessor :phone
    validates :phone, phone: true
  end

  let(:subject) { DummyPhone.new }

  describe 'valid phone numbers' do
    it 'accepts a valid 11-digit phone number (with 9 after area code)' do
      subject.phone = '(11) 99999-8888'
      expect(subject).to be_valid
    end

    it 'accepts a valid 10-digit phone number' do
      subject.phone = '(11) 9999-8888'
      expect(subject).to be_valid
    end

    it 'accepts phone number without formatting' do
      subject.phone = '11999998888'
      expect(subject).to be_valid
    end

    it 'accepts phone number with spaces' do
      subject.phone = '11 99999 8888'
      expect(subject).to be_valid
    end

    it 'accepts phone number with mixed formatting' do
      subject.phone = '(11) 99999-8888'
      expect(subject).to be_valid
    end

    it 'accepts a blank phone number' do
      subject.phone = ''
      expect(subject).to be_valid
    end

    it 'accepts a nil phone number' do
      subject.phone = nil
      expect(subject).to be_valid
    end

    it 'accepts valid phone with area codes from 11 to 99' do
      (11..99).each do |area_code|
        subject.phone = "(#{area_code}) 99999-8888"
        expect(subject).to be_valid, "Failed for area code #{area_code}"
      end
    end
  end

  describe 'invalid phone numbers' do
    it 'rejects phone with area code less than 11' do
      subject.phone = '(10) 99999-8888'
      expect(subject).not_to be_valid
      expect(subject.errors[:phone]).to include('deve ser um número de telefone válido no formato (XX) 9XXXX-XXXX ou (XX) XXXX-XXXX')
    end

    it 'rejects phone with area code 00' do
      subject.phone = '(00) 99999-8888'
      expect(subject).not_to be_valid
    end

    it 'rejects phone with too few digits' do
      subject.phone = '(11) 9999-888'
      expect(subject).not_to be_valid
    end

    it 'rejects phone with too many digits' do
      subject.phone = '(11) 999999-8888'
      expect(subject).not_to be_valid
    end

    it 'rejects phone number with all zeros in number part' do
      subject.phone = '(11) 0000-0000'
      expect(subject).not_to be_valid
    end

    it 'rejects phone number with repeated digits in number part' do
      subject.phone = '(11) 8888-8888'
      expect(subject).not_to be_valid
    end

    it 'rejects phone number with non-numeric characters' do
      subject.phone = '(11) 9999A-8888'
      expect(subject).not_to be_valid
    end
  end

  describe 'phone number normalization' do
    it 'handles phone with parentheses and hyphen' do
      subject.phone = '(85) 98765-4321'
      expect(subject).to be_valid
    end

    it 'handles phone with parentheses only' do
      subject.phone = '(85) 98765 4321'
      expect(subject).to be_valid
    end

    it 'handles phone with no formatting' do
      subject.phone = '85987654321'
      expect(subject).to be_valid
    end

    it 'handles phone with dots as separators' do
      subject.phone = '(85) 9876.5432'
      expect(subject).to be_valid
    end
  end

  describe 'area code validation' do
    it 'accepts area code 11 (São Paulo)' do
      subject.phone = '(11) 98765-4321'
      expect(subject).to be_valid
    end

    it 'accepts area code 85 (Ceará)' do
      subject.phone = '(85) 98765-4321'
      expect(subject).to be_valid
    end

    it 'accepts area code 99 (highest valid area code)' do
      subject.phone = '(99) 98765-4321'
      expect(subject).to be_valid
    end
  end
end
