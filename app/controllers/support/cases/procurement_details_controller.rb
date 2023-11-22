module Support
  class Cases::ProcurementDetailsController < Cases::ApplicationController
    before_action :set_back_url, :set_enums

    include HasDateParams
    include Concerns::HasInteraction

    def edit
      @case_procurement_details_form = CaseProcurementDetailsForm.new(**persisted_data)
    end

    def update
      @case_procurement_details_form = CaseProcurementDetailsForm.from_validation(validation)
      if validation.success?
        current_case.procurement.update!(@case_procurement_details_form.to_h)
        create_interaction(params[:case_id], "procurement_updated", "procurement details updated")

        redirect_to @back_url, notice: I18n.t("support.procurement_details.flash.updated")
      else
        render :edit
      end
    end

  private

    # Exposes instance variables of selected `Procurement` enums
    #
    # for example:
    #   @required_agreement_type # => %w[one_off ongoing]
    def set_enums
      %w[required_agreement_types
         stages
         route_to_markets
         reason_for_route_to_markets].each do |enum|
        instance_variable_set("@#{enum}", Support::Procurement.send(enum).keys)
      end
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "case-details")
    end

    def validation
      CaseProcurementDetailsFormSchema.new.call(**case_procurement_details_form_params)
    end

    def case_procurement_details_form_params
      form_params = params.require(:case_procurement_details_form).permit(:required_agreement_type, :route_to_market, :reason_for_route_to_market, :frameworks_framework_id)
      form_params[:started_at] = date_param(:case_procurement_details_form, :started_at)
      form_params[:ended_at] = date_param(:case_procurement_details_form, :ended_at)
      form_params
    end

    # @return [Hash]
    def persisted_data
      current_case.procurement.to_h.merge(framework_name: current_case.procurement.register_framework&.reference_and_name)
    end
  end
end
