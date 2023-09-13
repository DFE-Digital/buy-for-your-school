module Frameworks::ProviderContact::ActivityLogPresentable
  extend ActiveSupport::Concern

  def activity_log_display_name
    display_name
  end
end
