class ActivityLog::Types::RecordUpdatedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def title
    "#{@activity_log_item.subject_type.demodulize} #{activity_event}d".titleize
  end

  def presentable_changes
    @activity_log_item.activity.presentable_changes
  end

  def activity_event
    @activity_log_item.activity.event
  end
end
