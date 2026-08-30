class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    # Set password expiration to 24 hours from now
    # Use update_column to skip validations - safe since we're only updating internal state
    @user.update_column(:password_expires_at, 24.hours.from_now)
    mail subject: "Reset your password", to: user.email_address
  end
end
