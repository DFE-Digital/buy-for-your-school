# rubocop:disable Layout/AccessModifierIndentation
class Energy::OnboardingController < Energy::ApplicationController
  skip_before_action :authenticate_user!, :check_if_submitted
  before_action :remember_onboarding

  def start; end

  def guidance; end

  def before_you_start; end

  private

  def remember_onboarding
    session[:energy_onboarding] = true
  end
end
# rubocop:enable Layout/AccessModifierIndentation
