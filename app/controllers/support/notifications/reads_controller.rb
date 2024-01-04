module Support
  class Notifications::ReadsController < ApplicationController
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
      specified_redirection_path || support_notifications_path
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
