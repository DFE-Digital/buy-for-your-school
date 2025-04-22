module Energy
  class OnboardingController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :check_flag, :set_routing

    # /energy/onboarding/:step
    def show
      render @current_step
    end

    private

    # Remove this and before_action reference when flag removed
    def check_flag
      render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
    end

    # This will probably end up as a separate class - a routing brain
    def set_routing
      @current_step = params[:step] || :join_the_scheme
    end
  end
end
