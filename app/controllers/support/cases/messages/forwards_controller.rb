module Support
  class Cases::Messages::ForwardsController < Support::Cases::Messages::BaseController
    helper_method :back_to_url_b64

    def edit
      super

      @email_draft.subject = "Fw: #{current_email.subject}"
    end

    def create
      super

      @draft.forward_to_email = current_email
      @draft = @draft.save_draft!

      redirect_to redirect_url
    end

    def submit
      email_draft
      @email_draft.forward_to_email = current_email
      @email_draft.attributes = form_params

      super(deliver: :deliver_as_forward)
    end

    def back_to_url_b64
      return Base64.encode64(edit_support_case_message_forward_path(case_id: current_case.id, message_id: current_email.id, id: params[:id])) if action_name == "submit"

      current_url_b64
    end

  private

    def form_params
      params.require(:"message_reply_form_#{params[:unique_id]}")
            .permit(:html_content, :template_id, :blob_attachments, :subject, :to_recipients, :cc_recipients, :bcc_recipients, file_attachments: [])
    end

    def redirect_url
      return edit_support_case_message_forward_path(message_id: current_email.id, id: @draft.id) if params[:redirect_back].blank?

      url = URI.parse(url_for(params[:redirect_back]))
      query = URI.decode_www_form(url.query) << ["reply_frame_url", edit_support_case_message_forward_path(message_id: current_email.id, id: @draft.id)]
      url.query = URI.encode_www_form(query)
      url.to_s
    end
  end
end
