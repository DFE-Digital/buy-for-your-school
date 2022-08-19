module Support
  class Cases::Messages::RepliesController < Cases::ApplicationController
    before_action :current_email

    def create
      @reply_form = Messages::ReplyForm.from_validation(validation)

      if validation.success?
        @reply_form.reply_to_email(@current_email, current_agent)

        redirect_to support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id)
      else
        @reply_body = form_params[:body]
        @show_attachment_warning = Array(form_params[:attachments]).any?

        render :edit
      end
    end

  private

    def validation
      @validation ||= Messages::ReplyFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}").permit(:body, attachments: [])
    end

    def current_email
      @current_email = Support::Email.find(params[:message_id]) if params[:message_id].present?
    end
  end
end
