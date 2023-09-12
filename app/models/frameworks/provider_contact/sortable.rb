module Frameworks::ProviderContact::Sortable
  extend ActiveSupport::Concern

  included do
    scope :sort_by_name, ->(direction = "descending") { order("name #{safe_direction(direction)}") }
    scope :sort_by_provider_name, ->(direction = "descending") { joins(:provider).order("frameworks_providers.short_name #{safe_direction(direction)}") }
  end

  class_methods do
    def sorted_by(sort_by:, sort_order:)
      return sort_by_name("descending") unless sort_by.present? && sort_order.present?

      public_send("sort_by_#{sort_by}", sort_order)
    end

    def available_sort_options
      [
        %w[Name name],
        %w[Provider provider_name],
      ]
    end

    def safe_direction(direction)
      direction == "descending" ? "DESC" : "ASC"
    end
  end
end
