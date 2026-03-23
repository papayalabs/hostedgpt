module Agent
  class UsersController < Agent::ApplicationController
    require_unauthenticated_access except: :update

    before_action :ensure_registration_allowed, only: [:new, :create]
    before_action :set_user, only: [:update]

    layout "public"

    def new
      @user = Agent::User.new
      @user.errors.add(:base, flash[:errors]) if flash[:errors]
    end

    def create
      @user = Agent::User.new(user_create_params)

      if @user.save
        login_as(@user)
        redirect_to root_path, status: :see_other
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @user.update(user_update_params)
        Agent::Current.user.reload
        redirect_back fallback_location: root_path, status: :see_other
      else
        redirect_back fallback_location: root_path, status: :unprocessable_content
      end
    end

    private

    def ensure_registration_allowed
      if Agent::Feature.disabled?(:registration)
        head :not_found
      end
    end

    def set_user
      @user = Agent::Current.user if params[:id].to_i == Agent::Current.user.id
    end

    def user_create_params
      params.require(:agent_user).permit(:email, :first_name, :last_name, :password)
    end

    def user_update_params
      params.require(:agent_user).permit(preferences: [:nav_closed, :dark_mode])
    end
  end
end
