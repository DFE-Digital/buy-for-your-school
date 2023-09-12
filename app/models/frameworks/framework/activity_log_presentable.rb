module Frameworks::Framework::ActivityLogPresentable
  extend ActiveSupport::Concern

  def display_field_version_dfe_start_date(date)
    Date.parse(date).strftime("%d/%m/%y") if date.present?
  end

  def display_field_version_dfe_end_date(date)
    display_field_version_dfe_start_date(date)
  end
end
