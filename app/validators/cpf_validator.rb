class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # Remove common formatting characters
    clean_cpf = value.to_s.gsub(/[\.\-\/\s]/, "")

    unless valid_cpf?(clean_cpf)
      record.errors.add(attribute, "é inválido")
    end
  end

  private

  def valid_cpf?(cpf)
    return false if cpf.length != 11
    return false unless cpf.match?(/^\d+$/)
    return false if all_same_digits?(cpf)

    # Validate first check digit
    first_digit = calculate_digit(cpf[0...9], 10)
    return false if first_digit.to_s != cpf[9]

    # Validate second check digit
    second_digit = calculate_digit(cpf[0...10], 11)
    return false if second_digit.to_s != cpf[10]

    true
  end

  def calculate_digit(sequence, multiplier)
    sum = sequence.split("").each_with_index.sum { |digit, index| digit.to_i * (multiplier - index) }
    remainder = sum % 11
    remainder < 2 ? 0 : 11 - remainder
  end

  def all_same_digits?(cpf)
    cpf.match?(/^(\d)\1{10}$/)
  end
end
