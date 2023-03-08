module Notifications
  class NotificationsForAgent
    def initialize(agent_id:)
      @agent_id = agent_id
    end

    delegate :paginate, to: :query

    def any_unread?
      query.where(read: false).any?
    end

    def each(&block)
      return to_enum(:each) unless block_given?

      query.each(&block)
    end

  private

    def query
      Support::Notification.where(assigned_to_id: @agent_id).order("created_at DESC")
    end
  end
end
