module Support
  class Management::BaseController < ::Support::ApplicationController
  private

    def portal_scope = :support
    def authorize_agent_scope = :access_admin_settings?
  end
end
