module Support
  class Cases::MessagesController < Cases::ApplicationController
    def create
      @reply_form = Messages::ReplyForm.from_validation(validation)
      if validation.success?
        Messages::Send.new(body: @reply_form.body, kase: current_case, agent: current_agent).call
        redirect_to support_case_path(@current_case, anchor: "messages")
      else
        # redirect back to cases#show but with form errors?
        redirect_to support_case_path(@current_case, anchor: "messages")
      end
    end

  private

    # @return [ReplyFormSchema] validated form input
    def validation
      Messages::ReplyFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:message_reply_form).permit(:body)
    end
  end
end
