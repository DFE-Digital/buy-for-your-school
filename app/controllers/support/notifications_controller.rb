module Support
  class NotificationsController < ApplicationController
    def index
      @notifications = current_agent
        .assigned_to_notifications
        .order("created_at DESC")
        .paginate(page: params[:page])
    end

  private

    def authorize_agent_scope = :access_individual_cases?

    def notifications_portal
      (current_agent.roles & %w[cec cec_admin]).any? ? "cec" : "support"
    end

    helper_method def portal_notifications_mark_all_read_path
      send("#{notifications_portal}_notifications_mark_all_read_path")
    end
  end
end
