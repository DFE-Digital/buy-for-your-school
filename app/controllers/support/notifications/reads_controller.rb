module Support
  class Notifications::ReadsController < Support::NotificationsController
    def create
      @notification = Support::Notification.find(params[:notification_id])
      @notification.send(params.fetch(:mark_as, "read") == "unread" ? :mark_as_unread : :mark_as_read)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to redirection_path }
      end
    end

  private

    def redirection_path
      specified_redirection_path || ((current_agent.roles & %w[cec cec_admin]).any? || request.referer&.include?("cec/notifications") ? cec_notifications_path : support_notifications_path)
    end

    def specified_redirection_path
      return nil if params[:redirect_to].blank?

      Rails.application.routes.recognize_path(params[:redirect_to])

      params[:redirect_to]
    rescue ActionController::RoutingError
      nil
    end
  end
end
