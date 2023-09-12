class Frameworks::ActivityLogItem < ApplicationRecord
  include Presentable

  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :subject, polymorphic: true, optional: true
  delegated_type :activity, types: %w[Frameworks::ActivityLoggableVersion]

  before_create do
    self.guid ||= Current.request_id
    self.actor ||= Current.actor
  end
end
