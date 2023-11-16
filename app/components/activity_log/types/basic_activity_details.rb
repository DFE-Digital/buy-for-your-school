module ActivityLog::Types::BasicActivityDetails
  extend ActiveSupport::Concern

  included do
    attr_accessor :layout_component
  end

  def by
    @activity_log_item.actor.try(:full_name)
  end

  def date
    @activity_log_item.created_at
  end
end
