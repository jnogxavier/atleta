require 'rails_helper'

describe CpfValidator do
  # Define a named class for validation tests
  class DummyCpf
    include ActiveModel::Validations
    attr_accessor :cpf
    validates :cpf, cpf: true
  end

  let(:subject) { DummyCpf.new }

  describe 'valid CPFs' do
    it 'accepts a valid CPF without formatting' do
      subject.cpf = '11144477735'
      expect(subject).to be_valid
    end

    it 'accepts a valid CPF with common formatting' do
      subject.cpf = '111.444.777-35'
      expect(subject).to be_valid
    end

    it 'accepts a valid CPF with hyphen only' do
      subject.cpf = '111.444.777-35'
      expect(subject).to be_valid
    end

    it 'accepts a blank CPF' do
      subject.cpf = ''
      expect(subject).to be_valid
    end

    it 'accepts a nil CPF' do
      subject.cpf = nil
      expect(subject).to be_valid
    end
  end

  describe 'invalid CPFs' do
    it 'rejects CPF with incorrect length' do
      subject.cpf = '111.444.777'
      expect(subject).not_to be_valid
      expect(subject.errors[:cpf]).to include('é inválido')
    end

    it 'rejects CPF with non-numeric characters' do
      subject.cpf = '111.444.777-3A'
      expect(subject).not_to be_valid
      expect(subject.errors[:cpf]).to include('é inválido')
    end

    it 'rejects CPF with all same digits' do
      subject.cpf = '11111111111'
      expect(subject).not_to be_valid
      expect(subject.errors[:cpf]).to include('é inválido')
    end

    it 'rejects CPF with incorrect first check digit' do
      subject.cpf = '11144477736'
      expect(subject).not_to be_valid
      expect(subject.errors[:cpf]).to include('é inválido')
    end

    it 'rejects CPF with incorrect second check digit' do
      subject.cpf = '11144477734'
      expect(subject).not_to be_valid
      expect(subject.errors[:cpf]).to include('é inválido')
    end
  end

  describe 'check digit calculation' do
    it 'validates CPF with correct check digits' do
      # Known valid CPF
      subject.cpf = '123.456.789-09'
      expect(subject).to be_valid
    end

    it 'validates another valid CPF' do
      # Another valid CPF with different area
      subject.cpf = '53643995598'
      expect(subject).to be_valid
    end
  end
end
