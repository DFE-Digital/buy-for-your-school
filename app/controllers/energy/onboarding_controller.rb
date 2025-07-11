# rubocop:disable Layout/AccessModifierIndentation
class Energy::OnboardingController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :check_flag, :set_routing

  # /energy/onboarding/:step
  def show
    session[:energy_onboarding] = true
    render @current_step
  end

  private

  # Remove this and before_action reference when flag removed
  def check_flag
    render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
  end

  # This will probably end up as a separate class - a routing brain
  def set_routing
    permitted_steps = %w[join_the_scheme before_you_start guidance]
    back_urls = [
      "",
      energy_onboarding_path(:join_the_scheme),
      energy_onboarding_path(:join_the_scheme),
    ]
    step_position = permitted_steps.index(params[:step]) || 0
    @current_step = permitted_steps[step_position]
    @back_url = back_urls[step_position]
  end
end
# rubocop:enable Layout/AccessModifierIndentation
