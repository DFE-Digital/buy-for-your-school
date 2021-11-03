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

        # convert static UUIDs from the template into names
        # support/cases/emails/templates/index
        #
        template = {
          "What is a framework?": "f4696e59-8d89-4ac5-84ca-17293b79c337",
          "approaching suppliers": "6c76ed8c-030e-4c69-8f25-ea0c66091bc5",
          "list of suppliers": "12430165-4ae7-47aa-baa3-d0b3c5440a9b",
          "social value": "bb4e6925-3491-44b8-8747-bdbb31257403",
        }.invert.fetch(params[:email_template], "blank")

        # send email
        Support::Emails::ToSchool.new(
          recipient: @current_case,
          template: template,
          reference: @current_case.ref,
          variables: {
            to_name: "#{@current_case.first_name} #{@current_case.last_name}",
            text: @case_email_content_form.email_body,
            from_name: current_agent.full_name,
          }
        ).call


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
  end
end
