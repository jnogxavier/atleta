class CheckPlanStatusesJob < ApplicationJob
  queue_as :default

  def perform
    check_expired_plans
    check_expiring_plans

    Rails.logger.info "CheckPlanStatusesJob: Completed all plan status checks"
  end

  private

  def check_expired_plans
    # Loaded up front: the loop below suspends exactly the rows this relation
    # selects on, so re-querying it afterwards returns nothing and the admin
    # notifications never get created.
    expired_profiles = StudentProfile
      .where("expires_at IS NOT NULL")
      .where("expires_at < ?", Date.current)
      .where.not(status: "suspended")
      .includes(:user)
      .to_a

    expired_profiles.each do |profile|
      profile.update!(status: "suspended")
      create_expired_notification_for_student(profile)
    end

    # Batch admin notifications instead of looping per profile
    create_expired_notifications_for_all_admins(expired_profiles)

    Rails.logger.info "CheckPlanStatusesJob: Suspended #{expired_profiles.count} expired plans"
  end

  def check_expiring_plans
    expiring_profiles = StudentProfile
      .where("expires_at IS NOT NULL")
      .where("expires_at <= ?", 15.days.from_now)
      .where("expires_at > ?", Date.current)
      .includes(:user)

    # Use find_each to batch process and avoid loading all into memory
    expiring_profiles.find_each do |profile|
      create_expiring_notification_for_student(profile)
    end

    # Batch admin notifications instead of looping per profile
    create_expiring_notifications_for_all_admins(expiring_profiles)

    Rails.logger.info "CheckPlanStatusesJob: Processed #{expiring_profiles.count} expiring plans"
  end

  def create_expiring_notification_for_student(profile)
    days_until = (profile.expires_at - Date.current).to_i

    return if Notification.where(
      user: profile.user,
      notification_type: "expiration",
      created_at: Date.current.all_day
    ).exists?

    Notification.create!(
      user: profile.user,
      title: "Seu plano está próximo do vencimento",
      message: "Seu plano vence em #{days_until} #{days_until == 1 ? 'dia' : 'dias'} (#{I18n.l(profile.expires_at)}). Entre em contato para renovar.",
      notification_type: "expiration",
      action_url: "/student/dashboard"
    )
  end

  def create_expired_notification_for_student(profile)
    return if Notification.where(
      user: profile.user,
      notification_type: "error",
      created_at: Date.current.all_day
    ).exists?

    Notification.create!(
      user: profile.user,
      title: "Seu plano expirou",
      message: "Seu plano expirou em #{I18n.l(profile.expires_at)} e foi suspenso. Entre em contato para renovar e continuar utilizando nossos serviços.",
      notification_type: "error",
      action_url: "/student/dashboard"
    )
  end

  def create_expiring_notifications_for_all_admins(profiles)
    admins = User.where(role: "admin").includes(:notifications)

    profiles.find_each do |profile|
      days_until = (profile.expires_at - Date.current).to_i

      admins.each do |admin|
        next if Notification.where(
          user: admin,
          notification_type: "expiration",
          created_at: Date.current.all_day,
          metadata: { student_profile_id: profile.id }
        ).exists?

        Notification.create!(
          user: admin,
          title: "Plano de aluno próximo do vencimento",
          message: "O plano de #{profile.name} vence em #{days_until} #{days_until == 1 ? 'dia' : 'dias'} (#{I18n.l(profile.expires_at)}).",
          notification_type: "expiration",
          action_url: "/admin/dashboard",
          metadata: { student_profile_id: profile.id }
        )
      end
    end
  end

  def create_expired_notifications_for_all_admins(profiles)
    admins = User.where(role: "admin").includes(:notifications)

    profiles.each do |profile|
      admins.each do |admin|
        next if Notification.where(
          user: admin,
          notification_type: "warning",
          created_at: Date.current.all_day,
          metadata: { student_profile_id: profile.id, action: "suspended" }
        ).exists?

        Notification.create!(
          user: admin,
          title: "Plano de aluno expirado e suspenso",
          message: "O plano de #{profile.name} expirou em #{I18n.l(profile.expires_at)} e foi automaticamente suspenso.",
          notification_type: "warning",
          action_url: "/admin/dashboard",
          metadata: { student_profile_id: profile.id, action: "suspended" }
        )
      end
    end
  end
end
