# rubocop:disable Layout/AccessModifierIndentation
class Energy::OnboardingController < Energy::ApplicationController
  skip_before_action :authenticate_user!, :check_if_submitted
  before_action :set_routing

  # /energy/onboarding/:step
  def show
    session[:energy_onboarding] = true
    render @current_step
  end

  private

  # This will probably end up as a separate class - a routing brain
  def set_routing
    permitted_steps = %w[join_the_scheme before_you_start guidance]
    step_position = permitted_steps.index(params[:step]) || 0
    @current_step = permitted_steps[step_position]
  end
end
# rubocop:enable Layout/AccessModifierIndentation
