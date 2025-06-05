module Support
  class Notifications::MarkAllReadsController < Support::NotificationsController
    def create
      current_agent.assigned_to_notifications.mark_as_read

      redirect_to redirect_path
    end

  private

    def redirect_path
      (current_agent.roles & %w[cec cec_admin]).any? ? cec_notifications_path : support_notifications_path
    end
  end
end
