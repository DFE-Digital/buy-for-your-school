class ActivityLog::Types::StatusUpdatedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def status_badge(status)
    render "#{@activity_log_item.subject_type.underscore}s/status", status:
  end

  def from_status
    @activity_log_item.activity.field_changes["status"].first
  end

  def to_status
    @activity_log_item.activity.field_changes["status"].last
  end
end
