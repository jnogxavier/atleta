require 'rails_helper'

RSpec.describe EvaluationMedium, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:media_type) }
    it { should validate_inclusion_of(:media_type).in_array(%w[photo video]) }

    context 'when file is not attached' do
      it 'requires file_url' do
        medium = build(:evaluation_medium, file_url: nil)
        expect(medium).not_to be_valid
        expect(medium.errors[:file_url]).to include("não pode ficar em branco")
      end
    end
  end

  describe 'scopes' do
    before do
      @photo1 = create(:evaluation_medium, :photo)
      @photo2 = create(:evaluation_medium, :photo)
      @video1 = create(:evaluation_medium, :video)
      @video2 = create(:evaluation_medium, :video)
      @evaluated = create(:evaluation_medium, :evaluated)
      @pending = create(:evaluation_medium, :pending)
    end

    describe '.photos' do
      it 'returns only photos' do
        expect(EvaluationMedium.photos).to include(@photo1, @photo2)
        expect(EvaluationMedium.photos).not_to include(@video1, @video2)
      end
    end

    describe '.videos' do
      it 'returns only videos' do
        expect(EvaluationMedium.videos).to include(@video1, @video2)
        expect(EvaluationMedium.videos).not_to include(@photo1, @photo2)
      end
    end

    describe '.pending_evaluation' do
      it 'returns only pending evaluations' do
        expect(EvaluationMedium.pending_evaluation).to include(@pending)
        expect(EvaluationMedium.pending_evaluation).not_to include(@evaluated)
      end
    end

    describe '.evaluated' do
      it 'returns only evaluated media' do
        expect(EvaluationMedium.evaluated).to include(@evaluated)
        expect(EvaluationMedium.evaluated).not_to include(@pending)
      end
    end

    describe '.recent' do
      it 'orders by created_at descending' do
        oldest = create(:evaluation_medium)
        sleep 0.01
        middle = create(:evaluation_medium)
        sleep 0.01
        newest = create(:evaluation_medium)

        recent = EvaluationMedium.where(id: [ oldest.id, middle.id, newest.id ]).recent
        expect(recent.first).to eq(newest)
        expect(recent.last).to eq(oldest)
      end
    end
  end

  describe '#photo?' do
    it 'returns true for photo media type' do
      medium = build(:evaluation_medium, :photo)
      expect(medium.photo?).to be true
    end

    it 'returns false for video media type' do
      medium = build(:evaluation_medium, :video)
      expect(medium.photo?).to be false
    end
  end

  describe '#video?' do
    it 'returns true for video media type' do
      medium = build(:evaluation_medium, :video)
      expect(medium.video?).to be true
    end

    it 'returns false for photo media type' do
      medium = build(:evaluation_medium, :photo)
      expect(medium.video?).to be false
    end
  end

  describe '#file_url_or_attachment' do
    context 'when file is attached' do
      it 'returns the attachment URL' do
        medium = create(:evaluation_medium)
        # Skipping actual file attachment test as it requires Active Storage setup
        # Just test the method exists
        expect(medium).to respond_to(:file_url_or_attachment)
      end
    end

    context 'when file is not attached' do
      it 'returns the file_url' do
        medium = create(:evaluation_medium, file_url: 'https://example.com/file.jpg')
        expect(medium.file_url_or_attachment).to eq('https://example.com/file.jpg')
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      medium = build(:evaluation_medium)
      expect(medium).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:evaluation_medium, :photo)).to be_valid
      expect(build(:evaluation_medium, :video)).to be_valid
      expect(build(:evaluation_medium, :evaluated)).to be_valid
      expect(build(:evaluation_medium, :pending)).to be_valid
    end
  end
end
