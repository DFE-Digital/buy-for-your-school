module Support
  class Cases::RequestDetailsController < ::Support::Cases::ApplicationController
    def edit
      @case_request_details_form = CaseRequestDetailsForm.from_case(@current_case)
      @back_url = support_case_path(@current_case, anchor: "case-details")
    end

    def update
      @case_request_details_form = RequestDetailsFormPresenter.new(CaseRequestDetailsForm.from_validation(validation))
      @back_url = support_case_path(@current_case, anchor: "case-details")

      return render :update if submit_action == "confirm"
      return render :edit   if submit_action == "change"

      if validation.success?
        @case_request_details_form.update!(@current_case)

        redirect_to support_case_path(@current_case, anchor: "case-details")
      else
        render :edit
      end
    end

  private

    def submit_action
      params[:button]
    end

    def validation
      CaseRequestDetailsFormSchema.new.call(**case_request_details_form_params)
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
