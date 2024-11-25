module Frameworks::Framework::Sortable
  extend ActiveSupport::Concern

  included do
    scope :sort_by_updated, ->(direction = "descending") { order("frameworks_frameworks.updated_at #{safe_direction(direction)}") }
    scope :sort_by_dfe_review_date, ->(direction = "descending") { order("dfe_review_date #{safe_direction(direction)}") }
    scope :sort_by_provider_end_date, ->(direction = "descending") { order("provider_end_date #{safe_direction(direction)}") }
    scope :sort_by_reference, lambda { |direction = "descending"|
      sanitized_direction = safe_direction(direction)
      order(Arel.sql("regexp_replace(frameworks_frameworks.reference, '[^0-9]', '', 'g')::int") => sanitized_direction)
    }
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
        ["DfE review date", "dfe_review_date"],
        ["Provider end date", "provider_end_date"],
      ]
    end

    def safe_direction(direction)
      direction.to_s.match?(/\Adesc/i) ? "desc" : "asc"
    end
  end
end
