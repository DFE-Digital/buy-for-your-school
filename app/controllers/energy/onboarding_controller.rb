# rubocop:disable Layout/AccessModifierIndentation
class Energy::OnboardingController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :check_flag, :remember_onboarding

  def start; end

  def guidance; end

  def before_you_start; end

  private

  # Remove this and before_action reference when flag removed
  def check_flag
    render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
  end

  def remember_onboarding
    session[:energy_onboarding] = true
  end
end
# rubocop:enable Layout/AccessModifierIndentation
