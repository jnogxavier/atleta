class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless valid_phone?(value)
      record.errors.add(attribute, "deve ser um número de telefone válido no formato (XX) 9XXXX-XXXX ou (XX) XXXX-XXXX")
    end
  end

  private

  def valid_phone?(phone)
    # Remove common formatting characters
    clean_phone = phone.to_s.gsub(/[\s\-\(\).]/, "")

    # Brazilian phone numbers have 10-11 digits
    # Format: (XX) 9XXXX-XXXX (11 digits with 9 after area code) or (XX) XXXX-XXXX (10 digits)
    return false unless clean_phone.match?(/^\d{10,11}$/)

    # Area code should be between 11 and 99
    area_code = clean_phone[0...2].to_i
    return false if area_code < 11 || area_code > 99

    # Phone number should not be all zeros or same digits
    phone_number = clean_phone[2..-1]
    return false if phone_number.match?(/^0+$/) || phone_number.match?(/^(\d)\1+$/)

    true
  end
end
