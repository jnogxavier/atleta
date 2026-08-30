class Admin::VideosController < ApplicationController
  include AdminAuthorization

  before_action :set_student_profile, only: [ :new, :edit, :update ], if: -> { params[:student_id].present? }
  before_action :set_video, only: [ :edit, :update, :destroy ]

  ALLOWED_VIDEOABLE_TYPES = %w[
    StrengthExercise
    MobilityExercise
    CoreExercise
    CardioExercise
    StudentProfile
  ].freeze

  def index
    if params[:videoable_type].present? && params[:videoable_id].present?
      videoable_class = safe_constantize_videoable_type(params[:videoable_type])
      return render json: { error: "Invalid videoable type" }, status: :bad_request unless videoable_class

      begin
        @videoable = videoable_class.find(params[:videoable_id])
        @videos = @videoable.videos

        respond_to do |format|
          format.json do
            render json: VideoSerializer.render_collection(@videos, view: :detailed)
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found" }, status: :not_found
      end
    elsif params[:student_id].present?
      begin
        @student_profile = StudentProfile.find(params[:student_id])
        @videos = @student_profile.videos
        render :index
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Student profile not found" }, status: :not_found
      end
    else
      @videos = Video.all
      render :index
    end
  end

  def new
    @video = @student_profile.videos.build
  end

  def create
    if params[:videoable_type].present? && params[:videoable_id].present?
      videoable_class = safe_constantize_videoable_type(params[:videoable_type])
      unless videoable_class
        respond_to do |format|
          format.json { render json: { success: false, error: "Invalid videoable type" }, status: :bad_request }
          format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.invalid_videoable_type") }
        end
        return
      end

      begin
        @videoable = videoable_class.find(params[:videoable_id])
        @video = @videoable.videos.build(video_params)
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { success: false, error: "Resource not found" }, status: :not_found }
          format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.resource_not_found") }
        end
        return
      end

      if @video.save
        respond_to do |format|
          format.json { render json: { success: true, video: @video } }
          format.html { redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.video_created") }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, error: @video.errors.full_messages.join(", ") }, status: :unprocessable_entity }
          format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.video_creation_error") }
        end
      end
    else
      begin
        @student_profile = StudentProfile.find(params[:student_id])
        @video = @student_profile.videos.build(video_params)

        if @video.save
          redirect_to admin_student_videos_path(@student_profile),
                      notice: I18n.t("flash.notices.video_added")
        else
          render :new, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.student_not_found")
      end
    end
  end

  def edit
  end

  def update
    if @video.update(video_params)
      respond_to do |format|
        format.json { render json: { success: true, video: @video } }
        format.html { redirect_to admin_student_videos_path(@student_profile), notice: I18n.t("flash.notices.video_updated") }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: @video.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @video.destroy

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html do
        if @student_profile
          redirect_to admin_student_videos_path(@student_profile), notice: I18n.t("flash.notices.video_deleted")
        else
          redirect_to admin_dashboard_path, notice: I18n.t("flash.notices.video_deleted")
        end
      end
    end
  end

  private

  def safe_constantize_videoable_type(type)
    return nil unless ALLOWED_VIDEOABLE_TYPES.include?(type)
    type.constantize
  rescue NameError
    nil
  end

  def set_student_profile
    @student_profile = StudentProfile.find(params[:student_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { error: "Student profile not found" }, status: :not_found }
      format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.student_not_found") }
    end
  end

  def set_video
    @video = Video.find(params[:id])
    @student_profile = @video.videoable if @video.videoable_type == "StudentProfile"
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { error: "Video not found" }, status: :not_found }
      format.html { redirect_to admin_dashboard_path, alert: I18n.t("flash.alerts.video_not_found") }
    end
  end

  def video_params
    params.require(:video).permit(:url, :description)
  end
end
