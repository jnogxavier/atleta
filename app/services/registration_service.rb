class RegistrationService
  ANAMNESE_ATTRIBUTES = %i[
    gender
    age
    height
    weight
    goal
    physical_activity_level
    health_conditions
    medications
    injuries
    dietary_restrictions
    sleep_hours
    stress_level
    smoking
    alcohol_consumption
    phone
    birth_date
    marital_status
    profession
    personality
    expectations
    training_availability
    training_location
    available_equipment
    digestion
    chewing
    heartburn
    gastritis
    reflux
    bowel_movement_scale
    urine_scale
    breakfast
    breakfast_time
    lunch
    lunch_time
    afternoon_snack
    afternoon_snack_time
    dinner
    dinner_time
    snacks_between_meals
    time_of_biggest_appetite
    eating_motivation
    eating_motivation_other
    satisfied_with_meals
    wake_up_time
    sleep_time
    cpf
    address
    routine_description
  ].freeze

  def self.save_personal_data(user, personal_data_params)
    new.save_personal_data(user, personal_data_params)
  end

  def self.save_anamnese(user, anamnese_params)
    new.save_anamnese(user, anamnese_params)
  end

  def self.finalize_registration(user, audio_file: nil, evaluation_media: nil)
    new.finalize_registration(user, audio_file: audio_file, evaluation_media: evaluation_media)
  end

  def save_personal_data(user, personal_data_params)
    user.assign_attributes(
      name: personal_data_params[:name],
      email_address: personal_data_params[:email_address],
      password: personal_data_params[:password],
      password_confirmation: personal_data_params[:password_confirmation],
      role: :student,
      registration_status: :draft
    )

    # Run validations through the model
    unless user.valid?
      return { success: false, errors: user.errors.full_messages }
    end

    # If validations pass, save with full ActiveRecord flow
    if user.save
      { success: true, user_id: user.id }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end

  def save_anamnese(user, anamnese_params)
    return { success: false, errors: [ "User not found" ] } unless user

    anamnese_attrs = ANAMNESE_ATTRIBUTES.reject { |attr| [ :eating_motivation, :eating_motivation_other ].include?(attr) }
    anamnese_params_hash = anamnese_params.permit(*anamnese_attrs, :eating_motivation_other, eating_motivation: [])

    # Process eating_motivation array into pipe-delimited string
    if anamnese_params_hash[:eating_motivation].is_a?(Array)
      motivations = anamnese_params_hash[:eating_motivation].reject(&:blank?)
      motivations << anamnese_params_hash[:eating_motivation_other] if anamnese_params_hash[:eating_motivation_other].present?
      anamnese_params_hash[:eating_motivation] = motivations.join("|||")
      anamnese_params_hash.delete(:eating_motivation_other)
    end

    anamnese = user.anamnese || user.build_anamnese
    anamnese.skip_audio_validation = true  # Skip audio/text validation in step 3

    if anamnese.update(anamnese_params_hash)
      { success: true }
    else
      errors = format_validation_errors(anamnese.errors)
      { success: false, errors: errors }
    end
  end

  def finalize_registration(user, audio_file: nil, evaluation_media: nil)
    return { success: false, errors: [ "User not found" ] } unless user
    # The anamnese carries the phone the admin queue is validated against, so a
    # registration without one cannot be finalised at all. Refuse before
    # touching anything rather than failing at the last step.
    return { success: false, errors: [ "Anamnese not found" ] } unless user.anamnese

    failure = nil

    # Every write below has to land or none of them can: a user marked complete
    # without its PendingRegistration is invisible to the admin approval queue.
    ActiveRecord::Base.transaction do
      user.registration_status = :complete
      user.terms_accepted = true

      unless user.save
        failure = user.errors.full_messages
        raise ActiveRecord::Rollback
      end

      if audio_file.present?
        audio_recording = user.audio_recording || user.build_audio_recording
        audio_recording.file.attach(audio_file)
        audio_recording.save!
      end

      # Re-validate anamnese with audio/text validation enabled
      user.anamnese.skip_audio_validation = false
      unless user.anamnese.valid?
        failure = format_validation_errors(user.anamnese.errors)
        raise ActiveRecord::Rollback
      end

      attach_evaluation_media(user, evaluation_media) if evaluation_media.present?

      unless user.student_profile
        StudentProfile.create!(
          user: user,
          name: user.name,
          status: :inactive,
          plan: nil
        )
      end

      PendingRegistration.create!(
        name: user.name,
        email: user.email_address,
        phone: user.anamnese.phone,
        status: :pending
      )
    end

    return { success: false, errors: failure } if failure

    { success: true, user: user }
  rescue => e
    Rails.logger.error("Registration finalize error: #{e.message}\n#{e.backtrace.join("\n")}")
    { success: false, errors: [ "Erro ao finalizar cadastro: #{e.message}" ] }
  end

  private

  # evaluation_media arrives as ActionController::Parameters keyed by index --
  # Rails parses evaluation_media[0][file], evaluation_media[1][file] into
  # {"0" => {...}, "1" => {...}} -- so it has to be permitted and converted to a
  # plain Hash before the values can be read.
  def attach_evaluation_media(user, evaluation_media)
    media_hash = if evaluation_media.is_a?(ActionController::Parameters)
      evaluation_media.permit!.to_h
    else
      evaluation_media
    end
    media_array = media_hash.is_a?(Hash) ? media_hash.values : [ media_hash ]

    media_array.each do |media_data|
      next if media_data.blank?
      next unless media_data.respond_to?(:[])

      file = media_data[:file]
      # A blank entry is a slot the student left empty, not an error.
      next if file.blank?
      next unless file.respond_to?(:read)

      medium = user.evaluation_media.build(
        file: file,
        media_type: media_data[:media_type] || "photo",
        category: media_data[:category],
        description: media_data[:description],
        evaluated: false,
        uploaded_at: Time.current
      )

      # An unusable upload is secondary to the registration itself, so it is
      # logged rather than allowed to roll the whole thing back.
      unless medium.save
        Rails.logger.error("Failed to save evaluation medium for user #{user.id}: #{medium.errors.full_messages.join(', ')}")
      end
    end
  end

  def format_validation_errors(errors)
    errors.map do |error|
      attr_str = error.attribute.to_s
      message = error.message

      if attr_str == "base"
        message
      else
        attr_name = I18n.t("activerecord.attributes.anamnese.#{attr_str}", default: attr_str.humanize)
        "#{attr_name} #{message}"
      end
    end
  end
end
