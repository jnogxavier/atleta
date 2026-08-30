module Admin
  class DashboardController < ApplicationController
    include AdminAuthorization

    def index
      @sort_column = params[:sort] || "status"
      # Whitelist allowed sort directions to prevent SQL injection
      @sort_direction = %w[asc desc].include?(params[:direction]&.downcase) ? params[:direction].downcase : "asc"

      @users = User.includes(:student_profile, :partner_profile)

      case @sort_column
      when "status"
        @users = @users.order(Arel.sql("CASE WHEN deactivated_at IS NULL THEN 0 ELSE 1 END #{@sort_direction}"))
                       .order(role: :asc, name: :asc, email_address: :asc)
      when "role"
        @users = @users.order(role: @sort_direction.to_sym, name: :asc, email_address: :asc)
      when "email"
        @users = @users.order(email_address: @sort_direction.to_sym)
      when "created_at"
        @users = @users.order(created_at: @sort_direction.to_sym)
      else
        @users = @users.order(Arel.sql("CASE WHEN deactivated_at IS NULL THEN 0 ELSE 1 END ASC"))
                       .order(role: :asc, name: :asc, email_address: :asc)
      end

      # Keep as lazy query - don't materialize entire users table into memory with .to_a
      # The view will handle rendering only what's needed

      if params[:search].present?
        respond_to do |format|
          format.json { render_students_search_results }
          format.html { load_dashboard_data }
        end
      else
        load_dashboard_data
      end
    end

    private

    def load_dashboard_data
      # Cache pending/approved/rejected registrations for 5 minutes
      cache_key = "admin:dashboard:registrations"
      cached_data = Rails.cache.read(cache_key)

      if cached_data.nil?
        cached_data = {
          pending_count: PendingRegistration.pending_only.count,
          approved_count: PendingRegistration.where(status: "approved").count,
          rejected_count: PendingRegistration.where(status: "rejected").count
        }
        Rails.cache.write(cache_key, cached_data, expires_in: 5.minutes)
      end

      # Fetch recent records (not cached, but limited)
      @pending_registrations = PendingRegistration.pending_only.recent
      @approved_registrations = PendingRegistration
        .where(status: "approved")
        .where("approved_at > ?", 14.days.ago)
        .order(approved_at: :desc)
        .limit(10)
      @rejected_registrations = PendingRegistration
        .where(status: "rejected")
        .where("rejected_at > ?", 14.days.ago)
        .order(rejected_at: :desc)
        .limit(10)
      @notifications = current_user.notifications.unread.recent
      # Include meal_foods to prevent N+1 when calculating total calories
      @nutrition_plans = NutritionPlan.includes(:student_profile, meals: :meal_foods).order(created_at: :desc).page(params[:nutrition_page]).per(8)
    end

    def render_students_search_results
      search_query = normalize_search(params[:search].to_s)
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = 7

      # Cache pending emails for 5 minutes to avoid repeated queries
      pending_emails = Rails.cache.fetch("admin:pending_registration_emails", expires_in: 5.minutes) do
        PendingRegistration.pending_only.pluck(:email)
      end

      students = StudentProfile
        .includes(user: :anamnese, trainings: [])
        .where(rejected: false)
        .joins(:user)
        .where.not(users: { email_address: pending_emails })
        .order(created_at: :desc)

      if search_query.present?
        students = students.where(
          "unaccent(LOWER(student_profiles.name)) ILIKE unaccent(?) OR unaccent(LOWER(users.email_address)) ILIKE unaccent(?) OR unaccent(LOWER(student_profiles.student_id)) ILIKE unaccent(?)",
          "%#{search_query}%",
          "%#{search_query}%",
          "%#{search_query}%"
        )
      end

      @approved_students = students.page(page).per(per_page)
      @search_query = search_query

      pagination_html = if @approved_students.total_pages > 1
        render_to_string(partial: "admin/dashboard/pagination", formats: [ :html ], locals: { approved_students: @approved_students })
      else
        ""
      end

      render json: {
        html: render_to_string(partial: "admin/dashboard/students_tab_items", formats: [ :html ], locals: { approved_students: @approved_students }),
        pagination_html: pagination_html,
        total_count: students.count,
        total_pages: @approved_students.total_pages,
        current_page: @approved_students.current_page
      }
    end
  end
end
