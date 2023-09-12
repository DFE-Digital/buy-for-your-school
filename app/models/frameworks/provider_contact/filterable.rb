module Frameworks::ProviderContact::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_provider, ->(provider_ids) { where(provider_id: Array(provider_ids)) }
  end

  class_methods do
    def filtering(params = {})
      Frameworks::ProviderContact::Filtering.new(params)
    end
  end
end
