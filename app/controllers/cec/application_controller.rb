class Cec::ApplicationController < ApplicationController
  include SupportAgents

private

  def authorize_agent_scope = :access_cec_portal?
  def portal_namespace = :cec
end
