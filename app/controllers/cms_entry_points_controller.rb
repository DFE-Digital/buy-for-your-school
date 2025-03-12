class CmsEntryPointsController < ApplicationController
  include SupportAgents

  skip_before_action :authorize_agent!

  def start = redirect_to home_page

private

  def record_ga? = false

  def home_page
    policy = policy(:cms_portal)

    if session[:email_evaluator_link].present?
      email_evaluator_link = session[:email_evaluator_link]
      return email_evaluator_link
    end

    return session[:email_school_buyer_link] if session[:email_school_buyer_link].present?
    return support_root_path if policy.access_proc_ops_portal?
    return engagement_root_path if policy.access_e_and_o_portal?
    return support_case_statistics_path if policy.access_statistics?
    return frameworks_root_path if policy.access_frameworks_portal?

    cms_no_roles_assigned_path
  end
end
