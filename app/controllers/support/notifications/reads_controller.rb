module Support
  class Notifications::ReadsController < ApplicationController
    def create
      ::Notifications::MarkAsRead.new.call(support_notification_id: params[:notification_id])

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
