require 'rails_helper'

RSpec.describe Anamnese, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:anamnese) }

    # Required basic fields
    describe 'basic information' do
      it { should validate_presence_of(:gender) }
      it { should validate_inclusion_of(:gender).in_array(%w[male female]) }
      it { should validate_presence_of(:age) }
      it { should validate_numericality_of(:age).only_integer.is_greater_than(0).is_less_than_or_equal_to(120) }
      it { should validate_presence_of(:height) }
      it { should validate_numericality_of(:height).is_greater_than(0) }
      it { should validate_presence_of(:weight) }
      it { should validate_numericality_of(:weight).is_greater_than(0) }
      it { should validate_presence_of(:goal) }
      it { should validate_presence_of(:physical_activity_level) }
    end

    # Required personal information
    describe 'personal information' do
      it { should validate_presence_of(:cpf) }
      it { should validate_length_of(:cpf).is_at_most(14) }
      it { should validate_presence_of(:address) }
      it { should validate_length_of(:address).is_at_most(200) }
    end

    # Sleep and routine
    describe 'sleep and routine' do
      it { should validate_presence_of(:sleep_hours) }
      it { should validate_numericality_of(:sleep_hours).only_integer.is_greater_than(0).is_less_than_or_equal_to(24) }
      it { should validate_presence_of(:profession) }
      it { should validate_length_of(:profession).is_at_most(100) }
      it { should validate_presence_of(:training_availability) }
      it { should validate_length_of(:training_availability).is_at_most(200) }
      it { should validate_presence_of(:wake_up_time) }
      it { should validate_length_of(:wake_up_time).is_at_most(10) }
      it { should validate_presence_of(:sleep_time) }
      it { should validate_length_of(:sleep_time).is_at_most(10) }
      it { should validate_presence_of(:time_of_biggest_appetite) }
      it { should validate_length_of(:time_of_biggest_appetite).is_at_most(50) }
      it { should validate_presence_of(:alcohol_consumption) }
      it { should validate_length_of(:alcohol_consumption).is_at_most(50) }

      it 'validates smoking is boolean' do
        anamnese = build(:anamnese, smoking: nil)
        expect(anamnese).not_to be_valid
        expect(anamnese.errors[:smoking]).to include('deve ser selecionado')
      end

      it { should validate_presence_of(:bowel_movement_scale) }
      it { should validate_length_of(:bowel_movement_scale).is_at_most(50) }
      it { should validate_presence_of(:urine_scale) }
      it { should validate_length_of(:urine_scale).is_at_most(50) }
    end

    # Training
    describe 'training' do
      it { should validate_presence_of(:training_location) }
      it { should validate_length_of(:training_location).is_at_most(200) }
      it { should validate_presence_of(:available_equipment) }
      it { should validate_length_of(:available_equipment).is_at_most(1000) }
    end

    # Meal schedule
    describe 'meal schedule' do
      it { should validate_presence_of(:breakfast) }
      it { should validate_length_of(:breakfast).is_at_most(500) }
      it { should validate_presence_of(:lunch) }
      it { should validate_length_of(:lunch).is_at_most(500) }
      it { should validate_presence_of(:afternoon_snack) }
      it { should validate_length_of(:afternoon_snack).is_at_most(500) }
      it { should validate_presence_of(:dinner) }
      it { should validate_length_of(:dinner).is_at_most(500) }
      it { should validate_length_of(:breakfast_time).is_at_most(10) }
      it { should validate_length_of(:lunch_time).is_at_most(10) }
      it { should validate_length_of(:afternoon_snack_time).is_at_most(10) }
      it { should validate_length_of(:dinner_time).is_at_most(10) }
    end

    # Digestion & Health
    describe 'digestion and health' do
      it { should validate_presence_of(:digestion) }
      it { should validate_length_of(:digestion).is_at_most(200) }
      it { should validate_presence_of(:chewing) }
      it { should validate_length_of(:chewing).is_at_most(200) }

      it 'validates heartburn is boolean' do
        anamnese = build(:anamnese, heartburn: nil)
        expect(anamnese).not_to be_valid
        expect(anamnese.errors[:heartburn]).to include('deve ser selecionado')
      end

      it 'validates reflux is boolean' do
        anamnese = build(:anamnese, reflux: nil)
        expect(anamnese).not_to be_valid
        expect(anamnese.errors[:reflux]).to include('deve ser selecionado')
      end

      it 'validates gastritis is boolean' do
        anamnese = build(:anamnese, gastritis: nil)
        expect(anamnese).not_to be_valid
        expect(anamnese.errors[:gastritis]).to include('deve ser selecionado')
      end
    end

    # Eating habits
    describe 'eating habits' do
      it { should validate_presence_of(:eating_motivation) }
      it { should validate_length_of(:eating_motivation).is_at_most(1000) }
      it { should validate_presence_of(:personality) }
      it { should validate_length_of(:personality).is_at_most(2000) }

      it 'validates snacks_between_meals is boolean' do
        anamnese = build(:anamnese, snacks_between_meals: nil)
        expect(anamnese).not_to be_valid
        expect(anamnese.errors[:snacks_between_meals]).to include('deve ser selecionado')
      end

      it { should validate_presence_of(:satisfied_with_meals) }
      it { should validate_length_of(:satisfied_with_meals).is_at_most(200) }
    end

    # Optional fields
    describe 'optional fields' do
      it { should validate_length_of(:health_conditions).is_at_most(1000) }
      it { should validate_length_of(:medications).is_at_most(500) }
      it { should validate_length_of(:injuries).is_at_most(500) }
      it { should validate_length_of(:dietary_restrictions).is_at_most(500) }
      it { should validate_length_of(:phone).is_at_most(20) }
      it { should validate_length_of(:marital_status).is_at_most(50) }
      it { should validate_length_of(:expectations).is_at_most(2000) }
      it { should validate_length_of(:stress_level).is_at_most(50) }
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      anamnese = build(:anamnese)
      expect(anamnese).to be_valid
    end

    it 'has a valid minimal factory' do
      anamnese = build(:anamnese, :minimal)
      expect(anamnese).to be_valid
    end
  end

  describe 'edge cases' do
    it 'rejects age below 1' do
      anamnese = build(:anamnese, age: 0)
      expect(anamnese).not_to be_valid
    end

    it 'rejects age above 120' do
      anamnese = build(:anamnese, age: 121)
      expect(anamnese).not_to be_valid
    end

    it 'rejects negative height' do
      anamnese = build(:anamnese, height: -1)
      expect(anamnese).not_to be_valid
    end

    it 'rejects negative weight' do
      anamnese = build(:anamnese, weight: -1)
      expect(anamnese).not_to be_valid
    end

    it 'rejects sleep_hours below 1' do
      anamnese = build(:anamnese, sleep_hours: 0)
      expect(anamnese).not_to be_valid
    end

    it 'rejects sleep_hours above 24' do
      anamnese = build(:anamnese, sleep_hours: 25)
      expect(anamnese).not_to be_valid
    end

    it 'rejects invalid gender' do
      anamnese = build(:anamnese)
      anamnese.gender = 'invalid'
      expect(anamnese).not_to be_valid
    end

    it 'accepts true for smoking' do
      anamnese = build(:anamnese, smoking: true)
      expect(anamnese).to be_valid
    end

    it 'accepts false for smoking' do
      anamnese = build(:anamnese, smoking: false)
      expect(anamnese).to be_valid
    end
  end

  describe 'creation with all required fields' do
    it 'successfully creates anamnese with all required fields' do
      user = create(:user)
      anamnese = Anamnese.create!(
        user: user,
        gender: 'male',
        age: 30,
        height: 180.0,
        weight: 80.0,
        goal: 'Lose weight',
        physical_activity_level: 'moderate',
        cpf: '11144477735',
        address: 'Test Address 123',
        sleep_hours: 8,
        profession: 'Engineer',
        training_availability: 'evening',
        wake_up_time: '06:00',
        sleep_time: '22:00',
        time_of_biggest_appetite: 'evening',
        alcohol_consumption: 'rarely',
        smoking: false,
        bowel_movement_scale: '4',
        urine_scale: '3',
        training_location: 'gym',
        available_equipment: 'Dumbbells, barbell',
        breakfast: 'Oats with milk',
        lunch: 'Rice and chicken',
        afternoon_snack: 'Fruits',
        dinner: 'Salad and fish',
        breakfast_time: '07:00',
        lunch_time: '12:00',
        afternoon_snack_time: '15:00',
        dinner_time: '19:00',
        digestion: 'good',
        chewing: 'normal',
        heartburn: false,
        reflux: false,
        gastritis: false,
        eating_motivation: 'Health and fitness',
        personality: 'Disciplined',
        snacks_between_meals: false,
        satisfied_with_meals: 'usually',
        phone: '(11) 98765-4321',
        stress_level: 'moderate',
        routine_description: 'Daily routine with exercise'
      )

      expect(anamnese).to be_persisted
      expect(anamnese.user).to eq(user)
    end
  end
end
