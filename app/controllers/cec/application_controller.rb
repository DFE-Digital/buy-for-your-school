class Cec::ApplicationController < ApplicationController
  include SupportAgents

private

  helper_method :notifications_unread?

  def authorize_agent_scope = :access_cec_portal?
  def portal_namespace = :cec

  def is_user_cec_agent?
    (current_agent.roles & %w[cec cec_admin]).any?
  end

  def agent_portal_namespace
    (current_agent.roles & %w[cec cec_admin]).any? ? "cec" : "support"
  end

  def notifications_unread?
    return false if current_agent.nil?

    current_agent.assigned_to_notifications.unread.any?
  end
end
