module Support
  class Cases::ProcurementDetailsController < Cases::ApplicationController
    # TODO: is it wiser to have a single action set multiple instance variables?
    before_action :set_back_url, :set_enums, :set_framework_names

    include Concerns::HasDateParams

    def edit
      @case_procurement_details_form = CaseProcurementDetailsForm.new(**current_case.procurement.to_h)
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

    # Exposes instance variables of selected `Procurement` enums
    #
    # for example:
    #   @required_agreement_type # => %w[one_off ongoing]
    def set_enums
      %w[required_agreement_types
         stages
         route_to_markets
         reason_for_route_to_markets].each do |enum|
        instance_variable_set("@#{enum}", Support::Case.send(enum).keys)
      end
    end

    def set_framework_names
      @framework_names = [[I18n.t("support.procurement_details.edit.framework_name.select"), nil]]
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
