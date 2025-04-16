module Support
  class Cases::MessagesController < Cases::ApplicationController
    before_action :current_email

    def create
      @reply_form = Email::Draft.new(form_params)

      if @reply_form.valid?(context: :new_message)
        @reply_form.queue_delivery(:as_new_message)

        redirect_to support_case_message_threads_path(case_id: current_case.id)
      else
        @body = form_params[:html_content]
        @subject = form_params[:subject]
        @to_recipients = form_params[:to_recipients]
        @cc_recipients = form_params[:cc_recipients]
        @bcc_recipients = form_params[:bcc_recipients]
        @show_attachment_warning = Array(form_params[:attachments]).any?

        render :edit
      end
    end

  private

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id, :blob_attachments, file_attachments: [])
    end

    def current_email
      @current_email = current_case.email
    end
  end
end
