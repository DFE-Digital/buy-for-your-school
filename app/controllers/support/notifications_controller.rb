module Support
  class NotificationsController < ApplicationController
    def index
      @notifications = current_agent
        .assigned_to_notifications
        .unread
        .paginate(page: params[:page])
    end
  end
end
