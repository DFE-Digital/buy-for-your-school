module Support
  class Cases::ClosuresController < Cases::ApplicationController
    class CaseCannotBeClosed < StandardError; end

    before_action :set_back_url, :set_reasons

    def new
      @current_case = CasePresenter.new(@current_case)
    end

    def create
      if current_case.resolved?
        change_case_state(to: :close, reason: :resolved)

        record_action(case_id: current_case.id, action: "close_case", data: { closure_reason: "Resolved case closed by agent" })

        redirect_to support_case_path(current_case, anchor: "case-history"),
                    notice: I18n.t("support.case_closures.flash.created")
      else
        redirect_to support_case_path(current_case), notice: I18n.t("support.case_closures.flash.error.other")
      end
    end

    def edit
      unless current_case.initial? && current_case.incoming_email?
        return redirect_to support_cases_path, notice: I18n.t("support.case_closures.flash.error.initial")
      end

      @form = CaseClosureForm.new
    end

    def update
      @form = CaseClosureForm.from_validation(validation)

      if validation.success?
        current_case.transaction do
          raise CaseCannotBeClosed unless current_case.initial? && current_case.incoming_email?

          reason = I18n.t("support.case_closures.edit.reasons.#{@form.reason}")
          change_case_state(
            to: :close,
            reason: @form.reason,
            info: ". Reason given: #{reason}",
          )
        end
        record_action(case_id: current_case.id, action: "close_case", data: { closure_reason: @form.reason })
        redirect_to support_cases_path, notice: I18n.t("support.case_closures.flash.updated")
      else
        render :edit
      end
    rescue CaseCannotBeClosed
      redirect_to support_cases_path, notice: I18n.t("support.case_closures.flash.error.initial")
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
