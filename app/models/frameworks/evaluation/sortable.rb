module Frameworks::Evaluation::Sortable
  extend ActiveSupport::Concern

  included do
    scope :sort_by_updated, ->(direction = "descending") { order("frameworks_evaluations.updated_at #{safe_direction(direction)}") }
    scope :sort_by_reference, ->(direction = "descending") { order("frameworks_evaluations.reference #{safe_direction(direction)}") }
  end

  class_methods do
    def sorted_by(sort_by:, sort_order:)
      return sort_by_reference("descending") unless sort_by.present? && sort_order.present?

      public_send("sort_by_#{sort_by}", sort_order)
    end

    def available_sort_options
      [
        %w[Reference reference],
        %w[Updated updated],
      ]
    end

    def safe_direction(direction)
      direction == "descending" ? "DESC" : "ASC"
    end
  end
end
