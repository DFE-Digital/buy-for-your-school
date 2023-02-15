module Support
  class Notifications::ReadsController < ApplicationController
    def create
      ::Notifications::MarkAsRead.new.call(support_notification_id: params[:notification_id])
      redirect_to support_notifications_path
    end
  end
end
