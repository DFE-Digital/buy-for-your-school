module Support
  class Notifications::MarkAllReadsController < ApplicationController
    def create
      current_agent.assigned_to_notifications.mark_as_read

      redirect_to support_notifications_path
    end
  end
end
