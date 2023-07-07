module Engagement
  class ApplicationController < ::ApplicationController
    include SupportAgents

    helper_method :current_url_b64

  protected

    def back_link_param(back_to = params[:back_to])
      return if back_to.blank?

      Base64.decode64(back_to)
    end

    def current_url_b64(tab = "")
      Base64.encode64("#{request.fullpath}##{tab.to_s.dasherize}")
    end

  private

    def record_ga? = false

    def support? = false

    def engagement? = true

    def pundit_user = current_agent

    def authorize_agent_scope = :access_e_and_o_portal?
  end
end
