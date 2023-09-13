module Frameworks::ProviderContact::Presentable
  extend ActiveSupport::Concern

  def provider_name
    provider.name || provider.short_name
  end

  def display_name
    "#{name} (#{email})"
  end
end
