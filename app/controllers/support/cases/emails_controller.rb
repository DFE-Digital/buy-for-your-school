module Support
  class Cases::EmailsController < Cases::ApplicationController
    def create
      @case_email_content_form = CaseEmailContentForm.from_validation(validation)

      if validation.success?
        # create interaction
        @current_case.interactions.email_to_school.create!(
          agent_id: current_agent.id,
          body: @case_email_content_form.email_body,
          additional_data: {
            email_template: email_template_uuid,
            email_subject: @case_email_content_form.email_subject,
          },
        )

        send_email_to_school

        redirect_to templated_messages_support_case_message_threads_path(@current_case)
      end
    end

  private

    def case_email_content_form_params
      params.require(:case_email_content_form).permit(:email_body, :email_subject, :email_template)
    end

    # @return [Dry::Validation::Result]
    def validation
      CaseEmailContentFormSchema.new.call(**case_email_content_form_params)
    end

    def email_template_uuid
      case_email_content_form_params.fetch(:email_template)
    end

    # @return [Notifications::Client::ResponseNotification, String] email or error message
    def send_email_to_school
      Support::Emails::ToSchool.new(
        recipient: CaseContactPresenter.new(@current_case),
        template: email_template_uuid,
        reference: @current_case.ref,
        variables: {
          from_name: current_agent.full_name,
        },
      ).call
    end
  end
end
