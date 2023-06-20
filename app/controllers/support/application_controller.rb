module Support
  class ApplicationController < ::ApplicationController
    include SupportAgents

  protected

    helper_method :current_url_b64, :url_b64, :notifications_unread?

    def record_action(case_id:, action:, data: {})
      Support::RecordAction.new(
        case_id:,
        action:,
        data:,
      ).call
    end

    def support? = true
    def record_ga? = false

    def notifications_unread?
      return false if current_agent.nil?

      ::Notifications::NotificationsForAgent.new(agent_id: current_agent.id).any_unread?
    end

    def current_url_b64(tab = "")
      Base64.encode64("#{request.fullpath}##{tab.to_s.dasherize}")
    end

    def url_b64(url)
      Base64.encode64(url)
    end

    def back_link_param(back_to = params[:back_to])
      return if back_to.blank?

      Base64.decode64(back_to)
    end

    def pundit_user = current_agent
    def authorize_agent_scope = :access_proc_ops_portal?
  end
end
