module Support
  class Cases::SummarySubmissionsController < Cases::ApplicationController
    before_action :set_back_url

    def edit
      @case_summary_form = CaseSummaryForm.new(**normalised_case_summary_for_params)
    end

    def update
      @case_summary_form = CaseSummaryForm.from_validation(validation)

      if validation.success?
        @current_case.update!(validation.to_h)

        record_action(case_id: current_case.id, action: "change_case_summary", data: validation.to_h)

        redirect_to support_case_path(@current_case, anchor: "case-details"), notice: I18n.t("support.case_summary.flash.updated")
      else
        render :edit
      end
    end

  private

    def set_back_url
      @back_url = edit_support_case_summary_path(@current_case)
    end

    def validation
      CaseSummaryFormSchema.new.call(**case_summary_form_params)
    end

    def case_summary_form_params
      params.require(:case_summary_form).permit(:value, :support_level)
    end

    def normalised_case_summary_for_params
      normalised_params = { support_level: case_summary_form_params[:support_level] }
      normalised_params[:value] = case_summary_form_params[:value].to_f if case_summary_form_params[:value].present?

      normalised_params
    end
  end
end
