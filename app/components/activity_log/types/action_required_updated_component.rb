class ActivityLog::Types::ActionRequiredUpdatedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def title
    "Action Required flag #{action_required ? 'added' : 'removed'}"
  end

  def action_required
    @activity_log_item.activity.field_changes["action_required"].last
  end
end
