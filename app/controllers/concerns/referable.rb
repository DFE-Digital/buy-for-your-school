module Referable
  extend ActiveSupport::Concern

private

  def remember_request_referrer
    session[:faf_referrer] = request_referral_link
    session.delete(:energy_case_tasks_path)
    session.delete(:energy_onboarding)
  end

  def request_referral_link
    params[:referred_by] ? Base64.decode64(params[:referred_by]) : request.referer || "direct"
  end

  def remember_energy_referrer
    session.delete(:email_evaluator_link)
    session.delete(:email_school_buyer_link)
    session.delete(:faf_referrer)
    session[:energy_onboarding] = true
  end
end
