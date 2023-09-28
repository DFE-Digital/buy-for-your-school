module Frameworks::Evaluation::ActivityLogPresentable
  extend ActiveSupport::Concern

  def specific_change_template_for(activity_loggable_version)
    return "evaluations/status" if activity_loggable_version.changed_fields_only?("status")
    return "evaluations/contact" if activity_loggable_version.changed_fields_only?("contact_id")
  end
end
