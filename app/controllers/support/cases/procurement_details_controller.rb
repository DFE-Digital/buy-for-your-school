module Support
  class Cases::ProcurementDetailsController < Cases::ApplicationController
    before_action :set_back_url, :set_required_agreement_types, :set_stages, :set_framework_names, :set_routes_to_market, :set_reasons_for_route_to_market

    include DateHelper

    def edit
      @case_procurement_details_form = CaseProcurementDetailsForm.new(**current_case.procurement.attributes.symbolize_keys)
    end

    def update
      @case_procurement_details_form = CaseProcurementDetailsForm.from_validation(validation)

      if validation.success?
        current_case.procurement.update!(@case_procurement_details_form.instance_values.except("messages").symbolize_keys)

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
      @stages = [[I18n.t("support.procurement_details.edit.stage.select"), nil]]
      @stages.push(*Support::Procurement.stages.keys.map { |stage| [I18n.t("support.procurement_details.stages.#{stage}"), stage] })
      @stages
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
      form_params[:started_at] = date_param(:started_at)
      form_params[:ended_at] = date_param(:ended_at)
      form_params
    end

    # @see DateHelper
    #
    # @return [String]
    def date_param(date_field)
      date = params.require(:case_procurement_details_form).permit(date_field)
      date_hash = { day: date["#{date_field}(3i)"], month: date["#{date_field}(2i)"], year: date["#{date_field}(1i)"] }
      format_date(date_hash).to_s
    end
  end
end
