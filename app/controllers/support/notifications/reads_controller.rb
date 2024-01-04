module Support
  class Notifications::ReadsController < ApplicationController
    def create
      Support::Notification.find(params[:notification_id])
        .send(params.fetch(:mark_as, "read") == "unread" ? :mark_as_unread : :mark_as_read)

      respond_to do |format|
        format.turbo_stream { @notification = Support::Notification.find(params[:notification_id]) }
        format.html { redirect_to redirection_path }
      end
    end

  private

    def redirection_path
      return support_notifications_path if params[:redirect_to].nil?

      Rails.application.routes.recognize_path(params[:redirect_to])
      params[:redirect_to]
    rescue ActionController::RoutingError
      support_notifications_path
    end
  end
end
