module Support
  class Notifications::MarkAllReadsController < ApplicationController
    def create
      ::Notifications::MarkAllAsRead.new.call(assigned_to_id: current_agent.id)

      respond_to do |format|
        format.html { redirect_to support_notifications_path }
      end
    end
  end
end
