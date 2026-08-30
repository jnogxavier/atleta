class AnamneseAnthropometricValidator < ActiveModel::Validator
  def validate(record)
    # Gender validation
    unless record.gender.blank?
      unless %w[male female].include?(record.gender)
        record.errors.add(:gender, "deve ser 'male' ou 'female'")
      end
    end

    # Age validation
    if record.age.present?
      unless record.age.is_a?(Integer) && record.age > 0 && record.age <= 120
        record.errors.add(:age, "deve ser um número entre 1 e 120")
      end
    end

    # Height validation
    if record.height.present? && !record.height.is_a?(Numeric) || record.height.to_f <= 0
      record.errors.add(:height, "deve ser um número positivo")
    end

    # Weight validation
    if record.weight.present? && !record.weight.is_a?(Numeric) || record.weight.to_f <= 0
      record.errors.add(:weight, "deve ser um número positivo")
    end
  end
end
