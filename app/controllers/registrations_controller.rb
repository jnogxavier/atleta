class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  # Valid-format placeholder used when a registration is captured without a
  # phone number (e.g. a JS-less submission that skipped the anamnese step).
  # PendingRegistration requires a phone in the (XX) 9XXXX-XXXX format, so we
  # cannot store a free-text sentinel such as "N/A" here.
  PLACEHOLDER_PHONE = "(11) 90000-0000".freeze

  def new
    @user = User.new
  end

  def check_email
    email = params[:email]
    # Don't reveal whether email exists to prevent user enumeration attacks
    # Always return success to prevent attackers from enumerating valid emails
    if email.present? && email.match?(/@/)
      render json: { success: true }
    else
      render json: { error: "Invalid email format" }, status: :unprocessable_entity
    end
  end

  def update_personal_data
    @user = User.find_by(id: session[:draft_user_id]) || User.new

    result = RegistrationService.save_personal_data(@user, params[:user])

    if result[:success]
      session[:draft_user_id] = result[:user_id]
      render json: { success: true, user_id: result[:user_id] }
    else
      render json: { success: false, errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def update_anamnese
    @user = User.find_by(id: session[:draft_user_id])

    unless @user
      return render json: { success: false, errors: [ "Registration session not found. Please start over." ] }, status: :unprocessable_entity
    end

    result = RegistrationService.save_anamnese(@user, params[:user][:anamnese_attributes])

    if result[:success]
      render json: { success: true }
    else
      render json: { success: false, errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def finalize
    @user = User.find_by(id: session[:draft_user_id])

    unless @user
      return render json: { success: false, errors: [ "Registration session not found. Please start over." ] }, status: :unprocessable_entity
    end

    result = RegistrationService.finalize_registration(
      @user,
      audio_file: params[:audio_file],
      evaluation_media: params[:evaluation_media]
    )

    if result[:success]
      session.delete(:draft_user_id)
      start_new_session_for result[:user]
      render json: { success: true, redirect_url: student_dashboard_path }
    else
      render json: { success: false, errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def create
    anamnese_data = params[:user][:anamnese_attributes] if params[:user]

    @pending_registration = PendingRegistration.new(
      name: params[:user][:name],
      email: params[:user][:email_address],
      phone: anamnese_data&.dig(:phone).presence || PLACEHOLDER_PHONE,
      status: :pending
    )

    if @pending_registration.save
      session[:pending_user_data] = {
        name: params[:user][:name],
        email_address: params[:user][:email_address],
        anamnese_attributes: anamnese_data,
        evaluation_media: params[:evaluation_media]&.permit(:media_type, :category, :description, :file)&.to_h
      }

      redirect_to root_path,
                  notice: "Cadastro realizado com sucesso! Aguarde a análise do administrador para liberar seu acesso.",
                  status: :see_other
    else
      @user = User.new(user_params.merge(role: :student))
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email_address,
      :password,
      :password_confirmation,
      :terms_accepted,
      anamnese_attributes: RegistrationService::ANAMNESE_ATTRIBUTES
    )
  end
end
