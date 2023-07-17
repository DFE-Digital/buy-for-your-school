module Support
  class Cases::SummariesController < ::Support::Cases::ApplicationController
    before_action :set_back_url

    def edit
      @case_summary_form = case_summary_form
    end

    def update
      @case_summary_form = RequestDetailsFormPresenter.new(case_summary_form)

      if validation.success?
        return render :update if submit_action == "confirm"
        return render :edit   if submit_action == "change"

        @case_summary_form.update_case_summary_details(kase: @current_case, agent_id: current_agent.id)

        redirect_to support_case_path(@current_case, anchor: "case-details")
      else
        render :edit
      end
    end

  private

    def set_back_url
      @back_url = if submit_action == "confirm"
                    edit_support_case_summary_path(@current_case, case_summary_form: validation.to_h)
                  else
                    support_case_path(@current_case, anchor: "case-details")
                  end
    end

    def submit_action
      params[:button]
    end

    def validation
      CaseSummaryFormSchema.new.call(**case_summary_form_params)
    end

    def case_summary_form
      form = if fields_pre_filled_in_params?
               CaseSummaryForm.from_validation(validation)
             else
               CaseSummaryForm.from_case(@current_case)
             end
      form.agent_id = current_agent.id
      form
    end

    def fields_pre_filled_in_params?
      case_summary_form_params.present?
    rescue ActionController::ParameterMissing
      false
    end

    def case_summary_form_params
      params.require(:case_summary_form).permit(
        :request_text,
        :request_type,
        :category_id,
        :other_category,
        :query_id,
        :other_query,
        :source,
        :value,
        :support_level,
        :procurement_stage_id,
        :submit,
      )
    end
  end
end
