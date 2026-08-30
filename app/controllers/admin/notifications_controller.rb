class Admin::NotificationsController < ApplicationController
  include AdminAuthorization

  def bulk_send
    recipient_type = params[:recipient_type]
    notification_type = params[:notification_type]
    title = params[:title]
    message = params[:message]
    action_url = params[:action_url]

    users = case recipient_type
    when "all"
      User.joins(:student_profile).distinct
    when "active"
      User.joins(:student_profile).merge(StudentProfile.active).distinct
    when "inactive"
      User.joins(:student_profile).merge(StudentProfile.inactive).distinct
    when "expiring_soon"
      User.joins(:student_profile)
          .where("student_profiles.expires_at <= ? AND student_profiles.expires_at >= ?",
                 15.days.from_now, Date.current)
          .distinct
    else
      User.none
    end

    count = 0
    users.find_each do |user|
      Notification.create!(
        user: user,
        title: title,
        message: message,
        notification_type: notification_type,
        action_url: action_url.presence
      )
      count += 1
    end

    recipient = count == 1 ? "aluno" : "alunos"
    redirect_to admin_dashboard_path,
                notice: I18n.t("flash.notices.notifications_sent", count: count, recipients: recipient)
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    redirect_back fallback_location: admin_dashboard_path
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: root_path, notice: I18n.t("flash.notices.all_notifications_read")
  end
end
