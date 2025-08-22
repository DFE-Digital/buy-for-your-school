module Support
  class Cases::Messages::ForwardsController < Cases::ApplicationController
    before_action :current_email
    before_action :back_url

    helper_method :back_to_url_b64

    def edit
      @reply_form = Email::Draft.find(params[:id])
      @reply_form.subject = "FwDD: #{current_email.subject}"
      @last_received_reply = Support::Messages::OutlookMessagePresenter.new(current_email)
    end

    def create
      @draft = Email::Draft.new(
        default_content: default_template,
        template_id: params[:template_id],
        ticket: current_case.to_model,
        forward_to_email: current_email,
      ).save_draft!
      redirect_to redirect_url
    end

    def submit
      # binding.pry
      @reply_form = Email::Draft.find(params[:id])
      @reply_form.forward_to_email = current_email
      @reply_form.subject = form_params[:subject]
      @reply_form.attributes = form_params

      if @reply_form.valid?
        @reply_form.save_draft!
        @reply_form.deliver_as_forward

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

    def back_to_url_b64
      return Base64.encode64(edit_support_case_message_forward_path(case_id: current_case.id, message_id: current_email.id, id: params[:id])) if action_name == "submit"

      current_url_b64
    end

  private

    def default_template
      if current_case.energy_onboarding_case?
        render_to_string(partial: "support/cases/messages/energy_reply_form_template")
      else
        render_to_string(partial: "support/cases/messages/reply_form_template")
      end
    end

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}")
            .permit(:html_content, :template_id, :blob_attachments, :subject, :to_recipients, :cc_recipients, :bcc_recipients, file_attachments: [])
    end

    def current_email
      @current_email = Support::Email.find(params[:message_id]) if params[:message_id].present?
    end

    def redirect_url
      return edit_support_case_message_forward_path(message_id: current_email.id, id: @draft.id) if params[:redirect_back].blank?

      url = URI.parse(url_for(params[:redirect_back]))
      query = URI.decode_www_form(url.query) << ["reply_frame_url", edit_support_case_message_forward_path(message_id: current_email.id, id: @draft.id)]
      url.query = URI.encode_www_form(query)
      url.to_s
    end

    def back_url
      @back_url = support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id)
    end
  end
end
