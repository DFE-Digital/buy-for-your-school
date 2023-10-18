module Support
  class Cases::Messages::RepliesController < Cases::ApplicationController
    before_action :current_email
    before_action :back_url

    def new
      @reply_form = Email::Draft.new(
        default_content: default_template,
        template_id: params[:template_id],
      )
      @last_received_reply = Support::Messages::OutlookMessagePresenter.new(Support::Email.find(params[:message_id]))
    end

    def create
      @reply_form = Email::Draft.new(form_params)

      if @reply_form.valid?
        @reply_form.delivery_as_reply

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

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :template_id, :blob_attachments, file_attachments: [])
    end

    def current_email
      @current_email = Support::Email.find(params[:message_id]) if params[:message_id].present?
    end

    def back_url
      @back_url = support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id)
    end
  end
end
