module Support
  class NotificationsController < ApplicationController
    def index
      @notifications = Support::Notification
        .feed(assigned_to: current_agent)
        .paginate(page: params[:page])
    end
  end
end
