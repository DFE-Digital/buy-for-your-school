module Support::Agent::Notifyable
  extend ActiveSupport::Concern

  included do
    has_many :assigned_to_notifications, class_name: "Support::Notification", inverse_of: :assigned_to
  end

  def notify_assigned_to_case(support_case:, assigned_by:)
    return if assigned_by == self

    assigned_to_notifications.case_assigned.create!(support_case:, assigned_by:)
  end
end
