module Support
  class ApplicationController < ::ApplicationController
    before_action :authenticate_agent!

  protected

    helper_method :current_agent, :current_url_b64

    # @return [Agent, nil]
    def current_agent
      Agent.find_by(dsi_uid: session[:dfe_sign_in_uid])
    end

    # @return [nil]
    def authenticate_agent!
      return if current_agent

      redirect_to support_root_path, notice: "You are not a recognised case worker"
    end

    def record_action(case_id:, action:, data: {})
      Support::RecordAction.new(
        case_id: case_id,
        action: action,
        data: data,
      ).call
    end

    def support?
      true
    end

    def current_url_b64(tab = "")
      Base64.encode64("#{request.fullpath}##{tab.to_s.dasherize}")
    end
  end
end
