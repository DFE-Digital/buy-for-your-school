module Support
  class Cases::SavingsController < Cases::ApplicationController
    before_action :set_back_url, :set_enums, only: %i[edit update]

    include Concerns::HasInteraction

    def edit
      @case_savings_form = CaseSavingsForm.new(**current_case.attributes.symbolize_keys)
    end

    def update
      if validation.success?
        current_case.update!(validation.to_h)
        create_interaction(params[:case_id], "savings_updated", "savings updated")

        redirect_to @back_url, notice: I18n.t("support.case_savings.flash.updated")
      else
        @case_savings_form = CaseSavingsForm.from_validation(validation)
        render :edit
      end
    end

  private

    def validation
      @validation ||= CaseSavingsFormSchema.new.call(**case_savings_form_params)
    end

    # Exposes instance variables of selected `Case` enums
    #
    # for example:
    #   @savings_statuses => %w[realised potential unrealised]
    def set_enums
      %w[savings_statuses
         savings_estimate_methods
         savings_actual_methods].each do |enum|
        instance_variable_set("@#{enum}", Support::Case.send(enum).keys)
      end
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "procurement-details")
    end

    def case_savings_form_params
      params
        .require(:case_savings_form)
        .permit(
          :savings_status,
          :savings_estimate_method,
          :savings_actual_method,
          :savings_estimate,
          :savings_actual,
        )
    end
  end
end
