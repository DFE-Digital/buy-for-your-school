module Frameworks::ProviderContact::ActivityLogPresentable
  extend ActiveSupport::Concern

  def activity_log_display_name
    "#{name} (#{email})"
  end
end
