module Energy
  class OnboardingController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :set_routing

    # /energy/onboarding/:step
    def show
      render @current_step
    end

    private

    # This will probably end up as a separate class - a routing brain
    def set_routing
      @current_step = params[:step] || :join_the_scheme
    end
  end
end
