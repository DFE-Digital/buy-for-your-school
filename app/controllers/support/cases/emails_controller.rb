module Support
  class Cases::EmailsController < Cases::ApplicationController
    def create
      @case_email_content_form = CaseEmailContentForm.from_validation(validation)

      if validation.success?

        # create interaction
        @current_case.interactions.email_to_school.create!(
          agent_id: current_agent.id,
          body: @case_email_content_form.email_body,
        )

        send_email_to_school

        redirect_to support_case_path(@current_case, anchor: "case-history")
      end
    end

  private

    def validation
      CaseEmailContentFormSchema.new.call(**case_email_content_form_params)
    end

    def case_email_content_form_params
      params.require(:case_email_content_form).permit(:email_body, :email_subject, :email_template)
    end

    def send_email_to_school
      Support::Emails::ToSchool.new(
        recipient: @current_case,
        template: params.fetch(:email_template, "ac679471-8bb9-4364-a534-e87f585c46f3"),
        reference: @current_case.ref,
        variables: {
          text: @case_email_content_form.email_body,
          from_name: current_agent.full_name,
        },
      ).call
    end
  end
end
