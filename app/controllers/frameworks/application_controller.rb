class Frameworks::ApplicationController < ApplicationController
  include SupportAgents

private

  def authorize_agent_scope = :access_frameworks_portal?
  def portal_namespace = :frameworks
end
