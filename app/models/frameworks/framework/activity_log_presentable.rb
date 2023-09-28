module Frameworks::Framework::ActivityLogPresentable
  extend ActiveSupport::Concern

  def specific_change_template_for(activity_loggable_version)
    "frameworks/status" if activity_loggable_version.changed_fields_only?("status")
  end

  def activity_log_display_name
    reference_and_name
  end

  def display_field_version_dfe_start_date(date)
    Date.parse(date).strftime("%d/%m/%y") if date.present?
  end

  def display_field_version_dfe_end_date(date)
    display_field_version_dfe_start_date(date)
  end
end
