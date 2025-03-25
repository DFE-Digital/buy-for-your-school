module Support
  class Cases::EmailEvaluatorsController < Cases::ApplicationController
    helper_method :back_to_url_b64

    content_security_policy do |policy|
      policy.style_src_attr :unsafe_inline
    end

    before_action :set_current_case
    before_action :set_email_addresses
    before_action :set_documents
    before_action :set_template
    before_action { @back_url = support_case_path(@current_case, anchor: "tasklist") }

    def edit
      @draft = Email::Draft.new(
        default_content: default_template,
        default_subject:,
        template_id: @template_id,
        ticket: current_case.to_model,
        to_recipients: @to_recipients,
      ).save_draft!

      @support_email_id = @draft.id
      @email_evaluators = Email::Draft.find(@support_email_id)
      parse_template
    end

    def update
      @email_evaluators = Email::Draft.find(params[:id])
      @email_evaluators.attributes = form_params
      parse_template
      if @email_evaluators.valid?(:new_message)
        @email_evaluators.save_draft!
        @email_evaluators.deliver_as_new_message

        @current_case.update!(sent_email_to_evaluators: true)

        log_email_evaluators

        redirect_to @back_url
      else
        render :edit
      end
    end

    def back_to_url_b64
      return Base64.encode64(edit_support_case_message_thread_path(case_id: current_case.id, id: params[:id])) if action_name == "submit"

      current_url_b64
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def set_email_addresses
      @evaluators = @current_case.evaluators.all
      @email_addresses = @evaluators.map(&:email)
      @to_recipients = @email_addresses.to_json
    end

    def set_documents
      @documents = @current_case.upload_documents
    end

    def form_params
      params.require(:email_evaluators).permit(:html_content)
    end

    def draft_email_params
      params.require(:email_evaluators).permit(:id)
    end

    def default_subject = "Case #{current_case.ref} - invitation to complete procurement evaluation"

    def default_template = render_to_string(partial: "support/cases/email_evaluators/form_template")

    def set_template
      template = Support::EmailTemplate.find_by(title: "Invitation to complete procurement evaluation")
      @template_id = template.id if template
      @unique_link = evaluation_verify_evaluators_unique_link_path(@current_case, host: request.host)
    end

    def parse_template
      @email_evaluators.html_content = Support::EmailEvaluatorsVariableParser.new(@current_case, @email_evaluators, @unique_link).parse_template
    end

    def log_email_evaluators
      body = "Email sent to #{@to_recipients}"
      additional_data = { email_id: params[:id] }
      Support::EvaluationJourneyTracking.new(:email_evaluators, @current_case.id, body, additional_data).call
    end
  end
end
