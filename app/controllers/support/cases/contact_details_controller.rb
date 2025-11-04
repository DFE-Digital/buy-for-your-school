module Support
  class Cases::ContactDetailsController < Cases::ApplicationController
    def edit
      @case_contact_details_form = CaseContactDetailsForm.from_case(current_case)
    end

    def update
      @case_contact_details_form = CaseContactDetailsForm.from_validation(validation)
      @emails = current_case.case_additional_contacts&.pluck(:email)
      case_contact_details_form_params[:is_evaluator] = params[:is_evaluator] == "true" ? "true" : "false"
      if validation.success? && !@emails.include?(case_contact_details_form_params[:email])
        if @current_case.update!(case_contact_details_form_params)
          redirect_to contact_details_path(current_case, anchor: "school-details"), notice: I18n.t("support.case_contact_details.flash.updated")
        end
      else
        flash[:error] = { message: "Already a contact", class: "govuk-error" } if @emails.include?(case_contact_details_form_params[:email])
        render :edit
      end
    end

  private

    def validation
      CaseContactDetailsFormSchema.new.call(**case_contact_details_form_params)
    end

    helper_method def portal_case_contact_details_path(current_case)
      if (current_agent.roles & %w[cec cec_admin]).any?
        send("cec_case_update_contact_details_path", current_case)
      else
        send("support_case_contact_details_path", current_case)
      end
    end

    helper_method def contact_details_path(current_case, anchor: nil)
      if (current_agent.roles & %w[cec cec_admin]).any?
        send("cec_onboarding_case_path", current_case, anchor:)
      else
        send("support_case_path", current_case, anchor:)
      end
    end

    def case_contact_details_form_params
      params.require(:case_contact_details_form).permit(:first_name, :last_name, :phone_number, :email, :extension_number, :is_evaluator, :organisation_id, :organisation_type)
    end
  end
end
