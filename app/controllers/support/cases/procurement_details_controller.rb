module Support
  class Cases::ProcurementDetailsController < Cases::ApplicationController
    before_action :set_back_url, :set_required_agreement_types, :set_stages, :set_framework_names, :set_routes_to_market, :set_reasons_for_route_to_market

    include Concerns::HasDateParams

    def edit
      @case_procurement_details_form = CaseProcurementDetailsForm.new(**current_case.procurement.attributes.symbolize_keys)
    end

    def update
      @case_procurement_details_form = CaseProcurementDetailsForm.from_validation(validation)
      if validation.success?
        current_case.procurement.update!(@case_procurement_details_form.as_json.except("messages"))

        redirect_to @back_url, notice: I18n.t("support.procurement_details.flash.updated")
      else
        render :edit
      end
    end

  private

    def set_required_agreement_types
      @required_agreement_types = Support::Procurement.required_agreement_types.keys
    end

    def set_stages
      @stages = Support::Procurement.stages.keys
    end

    def set_framework_names
      @framework_names = [[I18n.t("support.procurement_details.edit.framework_name.select"), nil]]
      @framework_names
    end

    def set_routes_to_market
      @routes_to_market = Support::Procurement.route_to_markets.keys
    end

    def set_reasons_for_route_to_market
      @reasons_for_route_to_market = Support::Procurement.reason_for_route_to_markets.keys
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "procurement-details")
    end

    def validation
      CaseProcurementDetailsFormSchema.new.call(**case_procurement_details_form_params)
    end

    def case_procurement_details_form_params
      form_params = params.require(:case_procurement_details_form).permit(:required_agreement_type, :route_to_market, :reason_for_route_to_market, :framework_name, :stage)
      form_params[:started_at] = date_param(:case_procurement_details_form, :started_at).to_s
      form_params[:ended_at] = date_param(:case_procurement_details_form, :ended_at).to_s
      form_params
    end
  end
end
