# rubocop:disable Layout/AccessModifierIndentation
class Energy::OnboardingController < Energy::ApplicationController
  skip_before_action :authenticate_user!, :check_if_submitted
  before_action :remember_onboarding
  before_action :set_register_your_interest_form_url, only: :start

  def start; end

  def guidance; end

  def before_you_start; end

  private

  def remember_onboarding
    session.delete(:email_evaluator_link)
    session.delete(:email_school_buyer_link)
    session.delete(:faf_referrer)
    session[:energy_onboarding] = true
  end
end
# rubocop:enable Layout/AccessModifierIndentation
