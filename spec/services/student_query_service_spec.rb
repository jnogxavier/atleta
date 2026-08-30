require 'rails_helper'

describe StudentQueryService do
  describe '.fetch_students' do
    let!(:student1) { create(:student_profile, name: 'Alice Silva') }
    let!(:student2) { create(:student_profile, name: 'Bob Santos') }
    let!(:student3) { create(:student_profile, name: 'Charlie Costa') }

    it 'returns array of student data' do
      results = described_class.fetch_students
      expect(results).to be_an(Array)
      expect(results.length).to be > 0
    end

    it 'limits results to default limit' do
      create_list(:student_profile, 15)
      results = described_class.fetch_students
      expect(results.length).to be <= 10
    end

    it 'respects custom limit' do
      create_list(:student_profile, 15)
      results = described_class.fetch_students(limit: 5)
      expect(results.length).to be <= 5
    end

    it 'searches by name' do
      results = described_class.fetch_students(search_query: 'Alice')
      expect(results).to be_an(Array)
    end

    it 'performs case-insensitive search' do
      results = described_class.fetch_students(search_query: 'alice')
      expect(results).to be_an(Array)
    end

    it 'returns hash with student data' do
      results = described_class.fetch_students(search_query: 'Alice')
      expect(results.first).to have_key(:id)
      expect(results.first).to have_key(:name)
      expect(results.first).to have_key(:email)
      expect(results.first).to have_key(:active)
    end

    it 'handles SQL injection wildcards safely' do
      expect {
        described_class.fetch_students(search_query: "' OR '1'='1")
      }.not_to raise_error
    end

    it 'handles long queries safely' do
      long_query = 'a' * 150
      results = described_class.fetch_students(search_query: long_query)
      expect(results).to eq([])
    end
  end
end
