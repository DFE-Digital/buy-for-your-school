class Cec::ApplicationController < ApplicationController
  include SupportAgents

private

  helper_method :notifications_unread?

  def authorize_agent_scope = :access_cec_portal?
  def portal_namespace = :cec

  def notifications_unread?
    return false if current_agent.nil?

    current_agent.assigned_to_notifications.unread.any?
  end
end
