module Engagement
  class ApplicationController < ::ApplicationController
    include SupportAgents

  private

    def record_ga? = false
    def support? = false
    def engagement? = true
    def pundit_user = current_agent
    def authorize_agent_scope = :access_e_and_o_portal?
  end
end
