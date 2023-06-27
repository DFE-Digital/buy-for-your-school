module Support
  class Cases::Messages::RepliesController < Cases::ApplicationController
    before_action :current_email
    before_action :back_url

    def new
      @reply_form = Support::Messages::ReplyForm.new(
        default_template:,
        template_id: params[:template_id],
        parser: Support::Emails::Templates::Parser.new(agent: current_agent),
      )
      @last_received_reply = Support::Messages::OutlookMessagePresenter.new(Support::Email.find(params[:message_id]))
    end

    def create
      @reply_form = Messages::ReplyForm.from_validation(validation)

      if validation.success?
        @reply_form.reply_to_email(@current_email, current_case, current_agent)

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.redirect(support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id), "messages-frame")
          end
          format.html { redirect_to support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id) }
        end
      else
        @body = form_params[:body]
        @show_attachment_warning = Array(form_params[:attachments]).any?

        render :edit
      end
    end

  private

    def default_template = render_to_string(partial: "support/cases/messages/reply_form_template")

    def validation
      @validation ||= Messages::ReplyFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}").permit(:body, :template_id, :blob_attachments, file_attachments: [])
    end

    def current_email
      @current_email = Support::Email.find(params[:message_id]) if params[:message_id].present?
    end

    def back_url
      @back_url = support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id)
    end
  end
end
