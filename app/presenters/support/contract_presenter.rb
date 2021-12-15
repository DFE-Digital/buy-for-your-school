# frozen_string_literal: true

module Support
  class ContractPresenter < BasePresenter
    include ActionView::Helpers::NumberHelper

    # @return [String]
    def spend
      return "-" unless super

      number_to_currency(super, unit: "£", precision: 2)
    end

    # @return [String]
    def supplier
      super || "-"
    end

    # @return [String]
    def duration
      super&.inspect || "-"
    end

    # @return [String]
    def started_at
      return "-" unless super

      super.strftime(date_format)
    end

    # @return [String]
    def ended_at
      return "-" unless super

      super.strftime(date_format)
    end

    private

    # @return [String]
    def date_format
      I18n.t("date.formats.presenter")
    end
  end
end
