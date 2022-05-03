module Support
  class Cases::Messages::ReplyController < Cases::ApplicationController
    before_action :current_email, only: %i[show edit]

    def show
      @reply_body = templates(body: form_params[:body], agent: current_agent.full_name)
      @reply_form = Messages::ReplyForm.new(body: form_params[:body])
    end

    def edit
      @reply_form = Messages::ReplyForm.new(body: form_params[:body])
    end

  private

    def form_params
      params.require(:message_reply_form).permit(:body)
    end

    def current_email
      @current_email = Support::Email.find(params[:email])
    end

    def templates(params)
      Messages::Templates.new(params: params).call
    end
  end
end
