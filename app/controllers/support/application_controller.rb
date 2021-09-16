# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class ApplicationController < ActionController::Base
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    before_action :authenticate_agent!

    # protect_from_forgery

    protected

    helper_method :current_agent

    # @return [Agent, Guest]
    #
    def current_agent
      @current_agent ||= CurrentAgent.new.call(uid: session[:dfe_support_sign_in_uid])
    end

    # before_action - Ensure session is ended
    #
    # @return [nil]
    #
    def authenticate_agent!
      return unless current_agent.guest?

      session.delete(:dfe_support_sign_in_uid)
      redirect_to support_sign_in_path, notice: I18n.t("banner.session.visitor")
    end
  end

end
# :nocov:
