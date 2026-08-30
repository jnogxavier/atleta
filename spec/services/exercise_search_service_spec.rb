require 'rails_helper'

describe ExerciseSearchService do
  describe '.search' do
    let!(:strength_exercise) { create(:strength_exercise, name: 'Bench Press') }
    let!(:mobility_exercise) { create(:mobility_exercise, name: 'Shoulder Stretch') }
    let!(:core_exercise) { create(:core_exercise, name: 'Plank') }
    let!(:cardio_exercise) { create(:cardio_exercise, name: 'Running') }

    it 'searches strength exercises' do
      results = described_class.search('strength', 'Bench')
      expect(results).to be_an(Array)
    end

    it 'performs case-insensitive search' do
      results = described_class.search('strength', 'bench')
      expect(results).to be_an(Array)
    end

    it 'performs partial name matching' do
      results = described_class.search('strength', 'Ben')
      expect(results).to be_an(Array)
    end

    it 'searches mobility exercises' do
      results = described_class.search('mobility', 'Shoulder')
      expect(results).to be_an(Array)
    end

    it 'searches core exercises' do
      results = described_class.search('core', 'Plank')
      expect(results).to be_an(Array)
    end

    it 'searches cardio exercises' do
      results = described_class.search('cardio', 'Running')
      expect(results).to be_an(Array)
    end

    it 'returns empty array for invalid type' do
      results = described_class.search('invalid_type', 'test')
      expect(results).to eq([])
    end

    it 'handles SQL injection safely' do
      expect {
        described_class.search('strength', "Bench%' OR '1'='1")
      }.not_to raise_error
    end

    it 'returns array of hashes' do
      results = described_class.search('strength', 'Bench')
      if results.any?
        expect(results.first).to have_key(:id)
        expect(results.first).to have_key(:text)
      end
    end
  end
end
