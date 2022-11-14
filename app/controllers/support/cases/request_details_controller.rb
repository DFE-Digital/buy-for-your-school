module Support
  class Cases::RequestDetailsController < ::Support::Cases::ApplicationController
    before_action :set_back_url

    def edit
      @case_request_details_form = case_request_details_form
    end

    def update
      @case_request_details_form = RequestDetailsFormPresenter.new(case_request_details_form)

      if validation.success?
        return render :update if submit_action == "confirm"
        return render :edit   if submit_action == "change"

        @case_request_details_form.update!(@current_case)

        redirect_to support_case_path(@current_case, anchor: "case-details")
      else
        render :edit
      end
    end

  private

    def set_back_url
      @back_url = if submit_action == "confirm"
                    # Go back to edit
                    edit_support_case_request_details_path(@current_case, case_request_details_form: validation.to_h)
                  else
                    # Go back to case
                    support_case_path(@current_case, anchor: "case-details")
                  end
    end

    def submit_action
      params[:button]
    end

    def validation
      CaseRequestDetailsFormSchema.new.call(**case_request_details_form_params)
    end

    def case_request_details_form
      form = fields_pre_filled_in_params? \
        ? CaseRequestDetailsForm.from_validation(validation) \
        : CaseRequestDetailsForm.from_case(@current_case)
      form.agent_id = current_agent.id
      form
    end

    def fields_pre_filled_in_params?
      case_request_details_form_params.present?
    rescue ActionController::ParameterMissing
      false
    end

    def case_request_details_form_params
      params.require(:case_request_details_form).permit(
        :request_type,
        :category_id,
        :other_category,
        :query_id,
        :other_query,
        :request_text,
        :submit,
      )
    end
  end
end
