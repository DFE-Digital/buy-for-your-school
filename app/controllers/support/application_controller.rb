module Support
  class ApplicationController < ::ApplicationController
    before_action :authenticate_agent!

  protected

    helper_method :current_agent, :current_url_b64, :url_b64, :notifications_unread?

    # @return [Agent, nil]
    def current_agent
      ::Support::Agent.find_by(dsi_uid: session[:dfe_sign_in_uid])
    end

    # @return [nil]
    def authenticate_agent!
      return if current_agent

      redirect_to support_root_path, notice: "You are not a recognised case worker"
    end

    def record_action(case_id:, action:, data: {})
      Support::RecordAction.new(
        case_id:,
        action:,
        data:,
      ).call
    end

    def support?
      true
    end

    def notifications_unread?
      return false if current_agent.nil?

      Support::Notification.unread(assigned_to: current_agent).any?
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
  end
end
