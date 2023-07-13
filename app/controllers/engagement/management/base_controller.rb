module Engagement
  class Management::BaseController < ::Engagement::ApplicationController
  private

    def portal_scope = :engagement
    def authorize_agent_scope = :access_admin_settings?
  end
end
