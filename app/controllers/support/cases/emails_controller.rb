module Support
  class Cases::EmailsController < Cases::ApplicationController
    def create
      @case_email_content_form = CaseEmailContentForm.from_validation(validation)

      if validation.success?
        create_email_interaction(@case_email_content_form.email_body)

        redirect_to support_case_path(@current_case, anchor: "case-history")
      end
    end

  private

    def create_email_interaction(email_body)
      @current_case.interactions.email_to_school.create!(
        agent_id: current_agent.id,
        body: email_body,
      )
    end

    def validation
      CaseEmailContentFormSchema.new.call(**case_email_content_form_params)
    end

    def case_email_content_form_params
      params.require(:case_email_content_form).permit(:email_body, :email_subject)
    end
  end
end
