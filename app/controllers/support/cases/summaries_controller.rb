module Support
  class Cases::SummariesController < Cases::ApplicationController
    before_action :set_back_url

    def edit
      @case_summary_form = CaseSummaryForm.new(source: current_case.source, support_level: current_case.support_level, value: current_case.value)
    end

    def update
      @case_summary_form = CaseSummaryForm.from_validation(validation)

      if validation.success?
        redirect_to edit_support_case_summary_submission_path(current_case, case_summary_form: validation.to_h)
      else
        render :edit
      end
    end

  private

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "case-details")
    end

    def validation
      CaseSummaryFormSchema.new.call(**case_summary_form_params)
    end

    def case_summary_form_params
      params.require(:case_summary_form).permit(:source, :value, :support_level)
    end
  end
end
