module Support
  class Cases::Messages::MessagesController < Cases::ApplicationController
    before_action :current_email

    def create
      @form = Messages::ReplyForm.from_validation(validation)

      if validation.success?
        @form.create_new_message(@current_email, current_agent, @current_case.ref)

        redirect_to support_case_path(@current_case, anchor: "messages")
      else
        @body = form_params[:body]
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
      @current_email = current_case.email
    end
  end
end
