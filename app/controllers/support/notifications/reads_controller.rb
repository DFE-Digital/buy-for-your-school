module Support
  class Notifications::ReadsController < ApplicationController
    def create
      ::Notifications::MarkAsRead.new.call(support_notification_id: params[:notification_id])

      respond_to do |format|
        format.turbo_stream { @notification = Support::Notification.find(params[:notification_id]) }
        format.html { redirect_to support_notifications_path }
      end
    end
  end
end
