# frozen_string_literal: true

module Support
  class ContractPresenter < BasePresenter
    include ActionView::Helpers::NumberHelper
    include DateHelper

    # @return [String]
    def spend
      return "-" unless super

      number_to_currency(super, unit: "£", precision: 2)
    end

    # @return [String]
    def supplier
      super || "-"
    end

    # @return [String] "x seconds", "x days"
    def duration
      super ? super.inspect : "-"
    end

    # @return [String] "26 November 2021" or "-"
    def started_at
      super ? short_date_format(super, show_time: false, always_show_year: true) : "-"
    end

    # @return [String] "26 November 2021" or "-"
    def ended_at
      super ? short_date_format(super, show_time: false, always_show_year: true) : "-"
    end
  end
end
