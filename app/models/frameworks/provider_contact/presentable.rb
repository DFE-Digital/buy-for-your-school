module Frameworks::ProviderContact::Presentable
  extend ActiveSupport::Concern

  def provider_name
    provider.name || provider.short_name
  end
end
