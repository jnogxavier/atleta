module Admin
  class StudentsController < ApplicationController
    include AdminAuthorization

    before_action :set_student, only: [ :show, :edit, :update, :destroy ]

    def show
      @user = @student.user
      @anamnese = @user.anamnese
    end

    def new
      @student = StudentProfile.new
      @student.build_user
    end

    def create
      @user = User.new(user_params.merge(role: "student"))

      if @user.save
        @student = @user.create_student_profile!(student_params)
        redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.student_created")
      else
        @student = StudentProfile.new(student_params)
        @student.user = @user
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      user_update_params = user_params.reject { |k, v| v.blank? }

      if @student.update(student_params) && (user_update_params.empty? || @student.user.update(user_update_params))
        redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.student_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      user = @student.user
      @student.destroy
      user.destroy if user
      redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.student_deleted")
    end

    def autocomplete
      search_query = params[:q].to_s.strip
      limit = 10

      pending_emails = PendingRegistration.pending_only.pluck(:email)

      students = StudentProfile
        .where(rejected: false)
        .joins(:user)
        .where.not(users: { email_address: pending_emails })
        .select("student_profiles.id", :name, "users.id AS user_id", "users.email_address AS email")
        .order(:name)

      if search_query.present?
        normalized_query = "%#{search_query}%"
        students = students.where(
          "unaccent(LOWER(student_profiles.name)) ILIKE unaccent(?) OR " \
          "unaccent(LOWER(users.email_address)) ILIKE unaccent(?)",
          normalized_query,
          normalized_query
        )
      end

      render json: StudentProfileSerializer.render_collection(students.limit(limit), view: :summary)
    end

    def search
      search_query = params[:search].to_s.strip
      per_page = 7

      pending_emails = PendingRegistration.pending_only.pluck(:email)

      students = StudentProfile
        .includes(user: :anamnese)
        .where(rejected: false)
        .joins(:user)
        .where.not(users: { email_address: pending_emails })
        .order(created_at: :desc)

      if search_query.present?
        # Use unaccent for accent-insensitive search
        normalized_query = "%#{search_query}%"
        students = students.where(
          "unaccent(LOWER(student_profiles.name)) ILIKE unaccent(?) OR " \
          "unaccent(LOWER(users.email_address)) ILIKE unaccent(?) OR " \
          "LOWER(CAST(student_profiles.student_id AS VARCHAR)) LIKE ?",
          normalized_query,
          normalized_query,
          normalized_query
        )
      end

      @approved_students = students
        .page(params[:page])
        .per(per_page)

      pagination_html = if @approved_students.total_pages > 1
        render_to_string(partial: "admin/dashboard/pagination", formats: [ :html ], locals: { approved_students: @approved_students, search_query: search_query })
      else
        ""
      end

      render json: {
        html: render_to_string(partial: "admin/dashboard/students_tab_items", formats: [ :html ], locals: { approved_students: @approved_students }),
        pagination_html: pagination_html,
        total_count: @approved_students.total_count,
        total_pages: @approved_students.total_pages,
        current_page: @approved_students.current_page
      }
    end

    private

    def set_student
      @student = StudentProfile.find(params[:id])
    end

    def student_params
      params.require(:student_profile).permit(:name, :plan, :expires_at, :status, :student_id, :value)
    end

    def user_params
      params.require(:student_profile).permit(user_attributes: [ :email_address, :password, :password_confirmation ])[:user_attributes] || {}
    end
  end
end
