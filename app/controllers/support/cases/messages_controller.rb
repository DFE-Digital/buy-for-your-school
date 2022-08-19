module Support
  class Cases::MessagesController < Cases::ApplicationController
    before_action :current_email

    def create
      @reply_form = Messages::ReplyForm.from_validation(validation)

      if validation.success?
        @reply_form.create_new_message(@current_email, current_agent, @current_case.ref)

        redirect_to support_case_message_threads_path(case_id: current_case.id)
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
