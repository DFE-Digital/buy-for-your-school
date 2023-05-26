module Support
  class Cases::ContactDetailsController < Cases::ApplicationController
    def edit
      @case_contact_details_form = CaseContactDetailsForm.from_case(current_case)
    end

    def update
      @case_contact_details_form = CaseContactDetailsForm.from_validation(validation)

      if validation.success? && @case_contact_details_form.update_contact_details(current_case, current_agent.id)
        redirect_to support_case_path(current_case, anchor: "school-details"),
                    notice: I18n.t("support.case_contact_details.flash.updated")
      else
        render :edit
      end
    end

  private

    def validation
      CaseContactDetailsFormSchema.new.call(**case_contact_details_form_params)
    end

    def case_contact_details_form_params
      params.require(:case_contact_details_form).permit(:first_name, :last_name, :phone, :email, :extension_number)
    end
  end
end
