module Support
  class ApplicationController < ::ApplicationController
    include SupportAgents

  protected

    helper_method :current_url_b64, :url_b64, :notifications_unread?, :is_user_cec_agent?

    def record_action(case_id:, action:, data: {})
      Support::RecordAction.new(
        case_id:,
        action:,
        data:,
      ).call
    end

    def portal_namespace = :support

    def notifications_unread?
      return false if current_agent.nil?

      current_agent.assigned_to_notifications.unread.any?
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

    def is_user_cec_agent?
      (current_agent&.roles & %w[cec cec_admin]).any?
    end

    def agent_portal_namespace
      (current_agent&.roles & %w[cec cec_admin]).any? ? "cec" : "support"
    end

    def pundit_user = current_agent
    def authorize_agent_scope = :access_proc_ops_portal?

    def tracking_base_properties = super.merge(agent_id: current_agent.id)
  end
end
