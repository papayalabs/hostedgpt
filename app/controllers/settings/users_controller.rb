class Settings::UsersController < Settings::ApplicationController
  def edit
  end

  def update
    if Current.user.update(user_params)
      redirect_to edit_settings_user_path, notice: I18n.t("app.flashes.assistants.saved"), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, preferences: [:dark_mode])
  end
end
