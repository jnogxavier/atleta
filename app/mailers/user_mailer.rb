class UserMailer < ApplicationMailer
  default from: ENV["MAILER_FROM"] || "noreply@example.com"

  def temporary_password(user, password)
    @user = user
    @password = password
    @login_url = Rails.application.routes.url_helpers.new_session_url(host: ENV["DOMAIN"] || "example.com")

    mail(
      to: user.email_address,
      subject: "Sua Conta Atleta foi Aprovada - Acesse Agora"
    )
  end
end
