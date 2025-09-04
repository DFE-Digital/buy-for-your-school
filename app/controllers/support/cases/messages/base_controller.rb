module Support
  class Cases::Messages::BaseController < Cases::ApplicationController
    before_action :current_email
    before_action :back_url

    def edit
      @email_draft = Email::Draft.find(params[:id])
      @last_received_reply = Support::Messages::OutlookMessagePresenter.new(current_email)
    end

    def create
      @draft = Email::Draft.new(
        default_content: default_template,
        template_id: params[:template_id],
        ticket: current_case.to_model,
      )
    end

    def submit(deliver:, action: nil)
      if @email_draft.valid?(action)
        @email_draft.save_draft!
        @email_draft.send(deliver)

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.redirect(support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id), "messages-frame")
          end
          format.html { redirect_to support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id) }
        end
      else
        @last_received_reply = Support::Messages::OutlookMessagePresenter.new(current_email)
        render :edit
      end
    end

  private

    def email_draft
      @email_draft ||= Email::Draft.find(params[:id])
    end

    def default_template
      if current_case.energy_onboarding_case?
        render_to_string(partial: "support/cases/messages/energy_reply_form_template")
      else
        render_to_string(partial: "support/cases/messages/reply_form_template")
      end
    end

    def current_email
      @current_email = Support::Email.find(params[:message_id]) if params[:message_id].present?
    end

    def back_url
      @back_url = support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id)
    end
  end
end
