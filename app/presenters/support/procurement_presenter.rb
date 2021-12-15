# frozen_string_literal: true

module Support
  class ProcurementPresenter < BasePresenter
    # @return [String]
    def required_agreement_type
      return "-" unless super

      I18n.t("support.procurement_details.required_agreement_types.#{super}")
    end

    # @return [String]
    def route_to_market
      return "-" unless super

      I18n.t("support.procurement_details.routes_to_market.#{super}")
    end

    # @return [String]
    def reason_for_route_to_market
      return "-" unless super

      I18n.t("support.procurement_details.reasons_for_route_to_market.#{super}")
    end

    # @return [String]
    def stage
      return "-" unless super

      I18n.t("support.procurement_details.stages.#{super}")
    end

    # @return [String]
    def framework_name
      super || "-"
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
