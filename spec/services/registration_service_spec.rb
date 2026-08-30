require 'rails_helper'

describe RegistrationService do
  def params(hash)
    ActionController::Parameters.new(hash)
  end

  describe '.save_personal_data' do
    let(:valid) do
      {
        name: 'Maria Silva',
        email_address: 'maria@example.com',
        password: 'senha12345',
        password_confirmation: 'senha12345'
      }
    end

    it 'creates the user as a student still in draft' do
      result = described_class.save_personal_data(User.new, valid)

      expect(result[:success]).to be true
      user = User.find(result[:user_id])
      expect(user.role).to eq('student')
      expect(user.registration_status).to eq('draft')
      expect(user.authenticate('senha12345')).to be_truthy
    end

    it 'rejects a mismatched password confirmation without saving' do
      result = described_class.save_personal_data(
        User.new, valid.merge(password_confirmation: 'outra-senha')
      )

      expect(result[:success]).to be false
      expect(result[:errors]).to be_present
      expect(User.where(email_address: 'maria@example.com')).not_to exist
    end

    it 'rejects a password under the minimum length' do
      result = described_class.save_personal_data(
        User.new, valid.merge(password: 'curta', password_confirmation: 'curta')
      )

      expect(result[:success]).to be false
      expect(User.count).to eq(0)
    end

    it 'rejects a malformed email address' do
      result = described_class.save_personal_data(User.new, valid.merge(email_address: 'nao-e-email'))

      expect(result[:success]).to be false
      expect(User.count).to eq(0)
    end

    it 'rejects an email address already taken' do
      create(:user, email_address: 'maria@example.com')

      result = described_class.save_personal_data(User.new, valid)

      expect(result[:success]).to be false
      expect(User.where(email_address: 'maria@example.com').count).to eq(1)
    end
  end

  describe '.save_anamnese' do
    let(:user) { create(:user, :draft_student) }

    # The form posts eating_motivation as a multi-select and the service
    # permits it only as an array, so a scalar never survives `permit`.
    def answers(overrides = {})
      params(attributes_for(:anamnese).merge(eating_motivation: [ 'ansiedade' ]).merge(overrides))
    end

    it 'refuses a nil user rather than raising' do
      result = described_class.save_anamnese(nil, params({}))

      expect(result).to eq({ success: false, errors: [ 'User not found' ] })
    end

    it 'creates the anamnese from a full set of answers' do
      result = described_class.save_anamnese(user, answers)

      expect(result[:success]).to be true
      expect(user.reload.anamnese).to be_present
    end

    # Step 3 collects the routine as audio, which has not been uploaded yet, so
    # the audio-or-text check has to stay off until finalize.
    it 'accepts answers with no routine description yet' do
      result = described_class.save_anamnese(
        user, answers(routine_description: nil)
      )

      expect(result[:success]).to be true
    end

    it 'joins multi-select eating motivations into one delimited value' do
      described_class.save_anamnese(
        user,
        answers(eating_motivation: [ 'ansiedade', 'fome' ])
      )

      expect(user.reload.anamnese.eating_motivation).to eq('ansiedade|||fome')
    end

    it 'appends the free-text motivation and drops the blank entries' do
      described_class.save_anamnese(
        user,
        answers(eating_motivation: [ 'ansiedade', '' ], eating_motivation_other: 'tédio')
      )

      expect(user.reload.anamnese.eating_motivation).to eq('ansiedade|||tédio')
    end

    it 'updates an anamnese the user already has instead of creating a second' do
      create(:anamnese, user: user, weight: 70)

      described_class.save_anamnese(user, answers(weight: 82))

      expect(user.reload.anamnese.weight).to eq(82)
      expect(Anamnese.where(user: user).count).to eq(1)
    end

    it 'returns errors labelled with the translated attribute name' do
      result = described_class.save_anamnese(
        user, answers(cpf: '00000000000')
      )

      expect(result[:success]).to be false
      expect(result[:errors]).to be_present
      expect(result[:errors].join).not_to include('cpf ')
    end
  end

  describe '.finalize_registration' do
    let(:user) { create(:user, :draft_student) }
    let!(:anamnese) { create(:anamnese, user: user, phone: '(11) 98765-4321') }

    let(:audio) do
      { io: StringIO.new('audio'), filename: 'rotina.webm', content_type: 'audio/webm', identify: false }
    end
    let(:photo) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.png'), 'image/png')
    end

    it 'refuses a nil user rather than raising' do
      result = described_class.finalize_registration(nil)

      expect(result).to eq({ success: false, errors: [ 'User not found' ] })
    end

    it 'completes the registration and accepts the terms' do
      result = described_class.finalize_registration(user)

      expect(result[:success]).to be true
      expect(user.reload.registration_status).to eq('complete')
      expect(user.terms_accepted).to be true
    end

    it 'creates the student profile inactive, awaiting admin approval' do
      described_class.finalize_registration(user)

      profile = user.reload.student_profile
      expect(profile).to be_present
      expect(profile.status).to eq('inactive')
    end

    it 'does not replace a student profile the user already has' do
      existing = create(:student_profile, user: user)

      expect { described_class.finalize_registration(user) }
        .not_to change { StudentProfile.where(user: user).count }
      expect(user.reload.student_profile.id).to eq(existing.id)
    end

    it 'queues the registration for admin review with the anamnese phone' do
      described_class.finalize_registration(user)

      pending = PendingRegistration.find_by(email: user.email_address)
      expect(pending.status).to eq('pending')
      expect(pending.phone).to eq('(11) 98765-4321')
    end

    # PendingRegistration validates the phone against a strict Brazilian format,
    # so there is no placeholder that could stand in for a missing anamnese.
    it 'refuses to finalize a registration that has no anamnese' do
      anamnese.destroy!

      result = described_class.finalize_registration(user.reload)

      expect(result[:success]).to be false
      expect(PendingRegistration.count).to eq(0)
      expect(user.reload.registration_status).to eq('draft')
    end

    it 'attaches the routine audio recording' do
      described_class.finalize_registration(user, audio_file: audio)

      expect(user.reload.audio_recording.file).to be_attached
    end

    it 'attaches evaluation media as pending evaluation' do
      described_class.finalize_registration(
        user,
        evaluation_media: params({ '0' => { file: photo, category: 'frente', media_type: 'photo' } })
      )

      medium = user.reload.evaluation_media.first
      expect(medium.file).to be_attached
      expect(medium.category).to eq('frente')
      expect(medium.evaluated).to be false
    end

    it 'ignores evaluation media entries with no file' do
      described_class.finalize_registration(
        user,
        evaluation_media: params({ '0' => { category: 'frente', media_type: 'photo' } })
      )

      expect(user.reload.evaluation_media).to be_empty
    end

    # skip_audio_validation is lifted here, so a registration that reached the
    # last step with neither a routine description nor an audio is caught.
    it 'refuses to finalize when the routine has neither text nor audio' do
      anamnese.update_column(:routine_description, nil)

      result = described_class.finalize_registration(user)

      expect(result[:success]).to be false
      expect(result[:errors]).to be_present
      expect(PendingRegistration.count).to eq(0)
    end

    # A user left marked complete with no PendingRegistration never reaches the
    # admin approval queue, so a failure has to undo the whole step.
    it 'rolls the registration back rather than leaving it half finalized' do
      anamnese.update_column(:routine_description, nil)

      described_class.finalize_registration(user)

      expect(user.reload.registration_status).to eq('draft')
      expect(user.student_profile).to be_nil
      expect(PendingRegistration.count).to eq(0)
    end

    it 'accepts an audio recording in place of the routine description' do
      anamnese.update_column(:routine_description, nil)

      result = described_class.finalize_registration(user, audio_file: audio)

      expect(result[:success]).to be true
    end

    it 'returns the error instead of raising when a record cannot be created' do
      allow(PendingRegistration).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(PendingRegistration.new))

      result = described_class.finalize_registration(user)

      expect(result[:success]).to be false
      expect(result[:errors].first).to include('Erro ao finalizar cadastro')
    end
  end
end
