module Support
  class NotificationsController < ApplicationController
    def index
      @notifications = ::Notifications::NotificationsForAgent.new(agent_id: current_agent.id)
        .paginate(page: params[:page])
    end
  end
end
