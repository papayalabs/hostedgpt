class AuthenticationsController < ApplicationController
  require_unauthenticated_access only: [:new, :create]

  layout "public"

  def new
  end

  def create
    user = Agent::User.find_by(email: params[:email].to_s.downcase.strip)

    if user&.authenticate(params[:password])
      login_as(user)
      redirect_to root_path
      return
    end

    flash[:alert] = I18n.t("app.flashes.auth.invalid_login")
    redirect_to login_path(email: params[:email]), status: :see_other
  end

  def destroy
    logout_current
    redirect_to login_path
  end
end
