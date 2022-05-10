module Support
  class Cases::Messages::RepliesController < Cases::ApplicationController
    before_action :current_email, only: %i[show edit]

    def show
      @reply_body = templates(body: form_params[:body], agent: current_agent.full_name)
      @reply_form = Messages::ReplyForm.new(body: form_params[:body])
    end

    def edit
      @reply_form = Messages::ReplyForm.new(body: form_params[:body])
    end

    def create
      @reply_form = Messages::ReplyForm.from_validation(validation)

      if validation.success?
        @reply_form.reply_to_email(current_email, current_agent)

        redirect_to support_case_path(@current_case, anchor: "messages")
      else
        redirect_to support_case_message_reply_path(current_case, current_email)
      end
    end

  private

    def validation
      Messages::ReplyFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:message_reply_form).permit(:body, attachments: [])
    end

    def current_email
      @current_email = Support::Email.find(params[:message_id])
    end

    def templates(params)
      Messages::Templates.new(params: params).call
    end
  end
end
