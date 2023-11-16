class ActivityLog::Types::AssigneeUpdatedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def title
    "Assigned to agent: #{assignee_name}"
  end

  def assignee_name
    assignee = Support::Agent.find(@activity_log_item.activity.field_changes["assignee_id"].last)
    assignee.try(:full_name)
  end
end
