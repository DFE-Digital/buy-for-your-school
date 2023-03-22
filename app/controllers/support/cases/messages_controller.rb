module Support
  class Cases::MessagesController < Cases::ApplicationController
    before_action :current_email

    def create
      @reply_form = Messages::ReplyForm.from_validation(validation)

      if validation.success?
        @reply_form.create_new_message(current_case, current_agent)

        redirect_to support_case_message_threads_path(case_id: current_case.id)
      else
        @body = form_params[:body]
        @subject = form_params[:subject]
        @to_recipients = form_params[:to_recipients]
        @cc_recipients = form_params[:cc_recipients]
        @bcc_recipients = form_params[:bcc_recipients]
        @show_attachment_warning = Array(form_params[:attachments]).any?

        render :edit
      end
    end

  private

    def validation
      @validation ||= Messages::ReplyFormSchema.new.call(**form_params.merge(case_ref: current_case.ref))
    end

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}").permit(:body, :subject, :to_recipients, :cc_recipients, :bcc_recipients, attachments: [])
    end

    def current_email
      @current_email = current_case.email
    end
  end
end
