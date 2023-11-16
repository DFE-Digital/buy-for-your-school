class Frameworks::ActivityLogItem < ApplicationRecord
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :subject, polymorphic: true, optional: true
  delegated_type :activity, types: %w[Frameworks::ActivityLoggableVersion Frameworks::ActivityEvent]

  default_scope { order("created_at DESC") }

  before_create do
    self.guid ||= Current.request_id
    self.actor ||= Current.actor
    self.event_description ||= activity.activity_log_event_description
  end
end
