require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  describe '#welcome_message' do
    let(:user) { double('User', name: 'John Doe') }

    context 'when profile has a name and anamnese has female gender' do
      let(:profile) { double('Profile', name: 'Maria Silva') }
      let(:anamnese) { double('Anamnese', gender: 'female') }

      it 'returns female greeting with profile name' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vinda, Maria Silva')
      end
    end

    context 'when profile has a name and anamnese has male gender' do
      let(:profile) { double('Profile', name: 'João Santos') }
      let(:anamnese) { double('Anamnese', gender: 'male') }

      it 'returns male greeting with profile name' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, João Santos')
      end
    end

    context 'when profile has a name but anamnese is nil' do
      let(:profile) { double('Profile', name: 'Test User') }
      let(:anamnese) { nil }

      it 'returns male greeting as default with profile name' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, Test User')
      end
    end

    context 'when profile has a name and anamnese gender is nil' do
      let(:profile) { double('Profile', name: 'Test User') }
      let(:anamnese) { double('Anamnese', gender: nil) }

      it 'returns male greeting as default with profile name' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, Test User')
      end
    end

    context 'when profile is nil but user has a name' do
      let(:profile) { nil }
      let(:anamnese) { double('Anamnese', gender: 'male') }

      it 'returns male greeting with user name' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, John Doe')
      end
    end

    context 'when profile name is nil but user has a name' do
      let(:profile) { double('Profile', name: nil) }
      let(:anamnese) { double('Anamnese', gender: 'female') }

      it 'returns female greeting with user name' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vinda, John Doe')
      end
    end

    context 'when both profile and user name are nil' do
      let(:user) { double('User', name: nil) }
      let(:profile) { double('Profile', name: nil) }
      let(:anamnese) { double('Anamnese', gender: 'male') }

      it 'returns male greeting with default Aluno' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, Aluno')
      end
    end

    context 'when all parameters are nil' do
      let(:user) { double('User', name: nil) }
      let(:profile) { nil }
      let(:anamnese) { nil }

      it 'returns male greeting with default Aluno' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, Aluno')
      end
    end

    context 'when anamnese gender is other than male or female' do
      let(:profile) { double('Profile', name: 'Test User') }
      let(:anamnese) { double('Anamnese', gender: 'other') }

      it 'returns male greeting as default' do
        expect(helper.welcome_message(user, profile, anamnese)).to eq('Bem-vindo, Test User')
      end
    end
  end

  describe '#subscription_progress_percentage' do
    context 'when profile is nil' do
      it 'returns 0' do
        expect(helper.subscription_progress_percentage(nil)).to eq(0)
      end
    end

    context 'when profile expires_at is nil' do
      let(:profile) { double('Profile', expires_at: nil) }

      it 'returns 0' do
        expect(helper.subscription_progress_percentage(profile)).to eq(0)
      end
    end

    context 'when subscription is at the beginning' do
      let(:start_date) { Date.current }
      let(:expires_at) { Date.current + 30.days }
      let(:profile) { double('Profile', expires_at: expires_at, start_date: start_date, created_at: start_date.to_time) }

      it 'returns 0 percentage' do
        expect(helper.subscription_progress_percentage(profile)).to eq(0)
      end
    end

    context 'when subscription is halfway through' do
      let(:start_date) { Date.current - 15.days }
      let(:expires_at) { Date.current + 15.days }
      let(:profile) { double('Profile', expires_at: expires_at, start_date: start_date, created_at: start_date.to_time) }

      it 'returns 50 percentage' do
        expect(helper.subscription_progress_percentage(profile)).to eq(50)
      end
    end

    context 'when subscription is almost expired' do
      let(:start_date) { Date.current - 27.days }
      let(:expires_at) { Date.current + 3.days }
      let(:profile) { double('Profile', expires_at: expires_at, start_date: start_date, created_at: start_date.to_time) }

      it 'returns 90 percentage' do
        expect(helper.subscription_progress_percentage(profile)).to eq(90)
      end
    end

    context 'when subscription is expired' do
      let(:start_date) { Date.current - 40.days }
      let(:expires_at) { Date.current - 10.days }
      let(:profile) { double('Profile', expires_at: expires_at, start_date: start_date, created_at: start_date.to_time) }

      it 'returns 100 percentage (capped)' do
        expect(helper.subscription_progress_percentage(profile)).to eq(100)
      end
    end

    context 'when start_date is nil and uses created_at' do
      let(:created_at) { (Date.current - 10.days).to_time }
      let(:expires_at) { Date.current + 10.days }
      let(:profile) { double('Profile', expires_at: expires_at, start_date: nil, created_at: created_at) }

      it 'calculates percentage using created_at' do
        expect(helper.subscription_progress_percentage(profile)).to eq(50)
      end
    end

    context 'when percentage exceeds 100' do
      let(:start_date) { Date.current - 100.days }
      let(:expires_at) { Date.current - 50.days }
      let(:profile) { double('Profile', expires_at: expires_at, start_date: start_date, created_at: start_date.to_time) }

      it 'caps at 100' do
        expect(helper.subscription_progress_percentage(profile)).to eq(100)
      end
    end
  end

  describe '#days_remaining' do
    context 'when profile is nil' do
      it 'returns nil' do
        expect(helper.days_remaining(nil)).to be_nil
      end
    end

    context 'when profile expires_at is nil' do
      let(:profile) { double('Profile', expires_at: nil) }

      it 'returns nil' do
        expect(helper.days_remaining(profile)).to be_nil
      end
    end

    context 'when subscription expires in 30 days' do
      let(:expires_at) { Date.current + 30.days }
      let(:profile) { double('Profile', expires_at: expires_at) }

      it 'returns 30' do
        expect(helper.days_remaining(profile)).to eq(30)
      end
    end

    context 'when subscription expires today' do
      let(:expires_at) { Date.current }
      let(:profile) { double('Profile', expires_at: expires_at) }

      it 'returns 0' do
        expect(helper.days_remaining(profile)).to eq(0)
      end
    end

    context 'when subscription expires in 1 day' do
      let(:expires_at) { Date.current + 1.day }
      let(:profile) { double('Profile', expires_at: expires_at) }

      it 'returns 1' do
        expect(helper.days_remaining(profile)).to eq(1)
      end
    end

    context 'when subscription expired yesterday' do
      let(:expires_at) { Date.current - 1.day }
      let(:profile) { double('Profile', expires_at: expires_at) }

      it 'returns -1' do
        expect(helper.days_remaining(profile)).to eq(-1)
      end
    end

    context 'when subscription expired 10 days ago' do
      let(:expires_at) { Date.current - 10.days }
      let(:profile) { double('Profile', expires_at: expires_at) }

      it 'returns -10' do
        expect(helper.days_remaining(profile)).to eq(-10)
      end
    end
  end
end
