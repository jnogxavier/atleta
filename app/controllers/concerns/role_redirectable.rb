module RoleRedirectable
  extend ActiveSupport::Concern

  private

  def dashboard_path_for(user)
    case user.role
    when "admin"
      admin_dashboard_path
    when "student"
      student_dashboard_path
    when "partner"
      partner_dashboard_path
    else
      root_path
    end
  end
end
