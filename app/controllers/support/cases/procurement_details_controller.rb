module Support
  class Cases::ProcurementDetailsController < Cases::ApplicationController
    before_action :set_back_url, :set_required_agreement_types, :set_stages, :set_routes_to_market, :set_reasons_for_route_to_market

    def edit
      @case_procurement_details_form = CaseProcurementDetailsForm.new(**current_case.procurement.attributes.symbolize_keys)
    end

    def update; end

  private

    def set_required_agreement_types
      @required_agreement_types = Support::Procurement.required_agreement_types
    end

    def set_stages
      @stages = Support::Procurement.stages
    end

    def set_routes_to_market
      @routes_to_market = Support::Procurement.route_to_markets
    end

    def set_reasons_for_route_to_market
      @reasons_for_route_to_market = Support::Procurement.reason_for_route_to_markets
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "procurement-details")
    end
  end
end
