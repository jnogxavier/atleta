module DashboardHelper
  def welcome_message(user, profile, anamnese)
    name = profile&.name || user.name || "Aluno"
    gender = anamnese&.gender
    greeting = gender == "female" ? "Bem-vinda" : "Bem-vindo"
    "#{greeting}, #{name}"
  end

  def subscription_progress_percentage(profile)
    return 0 unless profile&.expires_at

    total_days = (profile.expires_at - (profile.start_date || profile.created_at.to_date)).to_i
    days_remaining = (profile.expires_at - Date.current).to_i

    [ ((total_days - days_remaining).to_f / total_days * 100).to_i, 100 ].min
  end

  def days_remaining(profile)
    return nil unless profile&.expires_at
    (profile.expires_at - Date.current).to_i
  end
end
