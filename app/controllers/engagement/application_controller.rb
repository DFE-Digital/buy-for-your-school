module Engagement
  class ApplicationController < ::ApplicationController
    include SupportAgents

  private

    def portal_namespace = :engagement

    def authorize_agent_scope = :access_e_and_o_portal?
  end
end
