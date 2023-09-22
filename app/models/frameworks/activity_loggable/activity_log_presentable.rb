module Frameworks::ActivityLoggable::ActivityLogPresentable
  extend ActiveSupport::Concern

  included do
    delegate :version_at, to: :paper_trail
  end

  def activity_log_display_name
    try(:full_name) || try(:short_name) || try(:name) || try(:reference)
  end

  def activity_log_display_short_name
    try(:short_name) || try(:reference)
  end

  def activity_log_display_type
    self.class.to_s.demodulize.underscore.humanize
  end
end
