module Support
  class Cases::ClosuresController < Cases::ApplicationController
    class CaseCannotBeClosed < StandardError; end

    before_action :set_back_url, :set_reasons

    def edit
      unless current_case.initial? && current_case.incoming_email?
        return redirect_to support_cases_path, notice: I18n.t("support.case_closures.flash.error")
      end

      @form = CaseClosureForm.new
    end

    def update
      @form = CaseClosureForm.from_validation(validation)

      if validation.success?
        current_case.transaction do
          raise CaseCannotBeClosed unless current_case.initial? && current_case.incoming_email?

          current_case.closed!
        end
        record_action(case_id: current_case.id, action: "close_case", data: { closure_reason: @form.reason })
        redirect_to support_cases_path, notice: I18n.t("support.case_closures.flash.updated")
      else
        render :edit
      end
    rescue CaseCannotBeClosed
      redirect_to support_cases_path, notice: I18n.t("support.case_closures.flash.error")
    end

  private

    def set_reasons
      @reasons = %i[spam out_of_scope other]
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "case-details")
    end

    def validation
      CaseClosureFormSchema.new.call(**case_closure_form_params)
    end

    def case_closure_form_params
      params.require(:case_closure_form).permit(:reason)
    end
  end
end
