module Student
  class PasswordController < ApplicationController
    include StudentOnlyAuthorization


    def edit
      @user = Current.user
    end

    def update
      @user = Current.user

      if @user.authenticate(password_params[:current_password])
        if @user.update(password: password_params[:password], password_confirmation: password_params[:password_confirmation])
          redirect_to student_dashboard_path, notice: I18n.t("flash.notices.password_changed")
        else
          flash.now[:alert] = I18n.t("flash.alerts.invalid_password")
          render :edit, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = I18n.t("flash.alerts.incorrect_password")
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
  end
end
