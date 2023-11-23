module Frameworks::Framework::ActivityLogPresentable
  extend ActiveSupport::Concern

  def activity_log_display_name
    reference_and_name
  end
end
