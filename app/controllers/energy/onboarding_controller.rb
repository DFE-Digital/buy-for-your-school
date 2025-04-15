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
      routing = %w[
        join_the_scheme
        before_you_start
        sign_in
        enter_password
      ]

      @current_step = params[:step] || routing[0]
      return unless routing.include?(@current_step)

      @next_step = routing[routing.index(@current_step) + 1]
      @prev_step = routing[routing.index(@current_step) - 1]
    end
  end
end
