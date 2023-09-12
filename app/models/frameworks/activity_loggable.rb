module Frameworks::ActivityLoggable
  extend ActiveSupport::Concern
  include ActivityLogPresentable

  included do
    has_paper_trail versions: { class_name: "Frameworks::ActivityLoggableVersion" }

    has_many :activity_log_items, as: :subject

    after_create :log_latest_version_in_activity_log
    after_update :log_latest_version_in_activity_log
  end

private

  def log_latest_version_in_activity_log
    Frameworks::ActivityLogItem.create!(subject: self, activity: versions.last, activity_type: "Frameworks::ActivityLoggableVersion")
  end
end
