module Frameworks::Provider::Sortable
  extend ActiveSupport::Concern

  included do
    scope :sort_by_short_name, ->(direction = "descending") { order("short_name #{safe_direction(direction)}") }
  end

  class_methods do
    def sorted_by(sort_by:, sort_order:)
      return sort_by_short_name("descending") unless sort_by.present? && sort_order.present?

      public_send("sort_by_#{sort_by}", sort_order)
    end

    def available_sort_options
      [
        ["Short Name", "short_name"],
      ]
    end

    def safe_direction(direction)
      direction == "descending" ? "DESC" : "ASC"
    end
  end
end
