module Frameworks::Framework::Sortable
  extend ActiveSupport::Concern

  included do
    scope :sort_by_updated, ->(direction = "descending") { order("frameworks_frameworks.updated_at #{safe_direction(direction)}") }
    scope :sort_by_dfe_start_date, ->(direction = "descending") { order("dfe_start_date #{safe_direction(direction)}") }
    scope :sort_by_dfe_end_date, ->(direction = "descending") { order("dfe_end_date #{safe_direction(direction)}") }
    scope :sort_by_provider_start_date, ->(direction = "descending") { order("provider_start_date #{safe_direction(direction)}") }
    scope :sort_by_provider_end_date, ->(direction = "descending") { order("provider_end_date #{safe_direction(direction)}") }
    scope :sort_by_reference, ->(direction = "descending") { order("frameworks_frameworks.reference #{safe_direction(direction)}") }
    scope :sort_by_provider_reference, ->(direction = "descending") { order("provider_reference #{safe_direction(direction)}") }
  end

  class_methods do
    def sorted_by(sort_by:, sort_order:)
      return sort_by_updated("descending") unless sort_by.present? && sort_order.present?

      public_send("sort_by_#{sort_by}", sort_order)
    end

    def available_sort_options
      [
        ["Updated", "updated"],
        ["Reference", "reference"],
        ["DfE start date", "dfe_start_date"],
        ["DfE end date", "dfe_end_date"],
        ["Provider start date", "provider_start_date"],
        ["Provider end date", "provider_end_date"],
      ]
    end

    def safe_direction(direction)
      direction == "descending" ? "DESC" : "ASC"
    end
  end
end
