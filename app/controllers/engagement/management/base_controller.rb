module Engagement
  class Management::BaseController < ::Engagement::ApplicationController
  private

    def authorize_agent_scope = :access_admin_settings?
  end
end
