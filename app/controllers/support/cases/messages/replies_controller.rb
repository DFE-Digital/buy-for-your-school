module Support
  class Cases::Messages::RepliesController < Cases::ApplicationController
    before_action :current_email
    before_action :back_url

    helper_method :back_to_url_b64

    def edit
      @reply_form = Email::Draft.find(params[:id])
      @last_received_reply = Support::Messages::OutlookMessagePresenter.new(current_email)
    end

    def create
      @draft = Email::Draft.new(
        default_content: default_template,
        template_id: params[:template_id],
        ticket: current_case.to_model,
        reply_to_email: [current_email],
        role: %w[Lead] + [current_case.is_evaluator == true ? "Evaulator" : ""],
      ).save_draft!

      redirect_to redirect_url
    end

    def submit
      @reply_form = Email::Draft.find(params[:id])
      emails = @reply_form.to_recipients.map(&:first)
      to_recipients_email = current_email.to_recipients.instance_of?(Array) ? current_email.to_recipients.map { |recipient| recipient["address"] } : [current_email.to_recipients["address"]]
      cc_recipients_email = current_email.cc_recipients.instance_of?(Array) ? current_email.cc_recipients.map { |recipient| recipient["address"] } : [current_email.cc_recipients["address"]]
      bcc_recipients_email = current_email.bcc_recipients.instance_of?(Array) ? current_email.bcc_recipients.map { |recipient| recipient["address"] } : [current_email.bcc_recipients["address"]]
      @reply_form.reply_to_email = current_email
      @reply_form.to_recipients = emails.present? ? emails.uniq.to_json : to_recipients_email.to_json
      @reply_form.cc_recipients =  @reply_form.cc_recipients.present? ? @reply_form.cc_recipients.map(&:first).to_json : cc_recipients_email.to_json
      @reply_form.bcc_recipients = @reply_form.bcc_recipients.present? ? @reply_form.bcc_recipients.map(&:first).to_json : bcc_recipients_email.to_json
      @reply_form.attributes = form_params
      @reply_form.email.to_recipients = emails
      @reply_form.reply_to_email.to_recipients = emails
      if @reply_form.valid?
        @reply_form.save_draft!
        @reply_form.delivery_as_reply

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
      return Base64.encode64(edit_support_case_message_reply_path(case_id: current_case.id, message_id: current_email.id, id: params[:id])) if action_name == "submit"

      current_url_b64
    end

    def add_recipient
      @reply_form = Email::Draft.find(params[:id])
      sender_email = current_email.sender.instance_of?(Array) ? [current_email.sender.map { |recipient| [recipient["address"], [""]] }] : [[current_email.sender["address"], [""]]]
      @sender_email = current_email.sender.instance_of?(Array) ? current_email.sender.map { |recipient| recipient["address"] } : [current_email.sender["address"]]
      current_case_role = current_case.is_evaluator ? ["Lead, Evaluator"] : %w[Lead]
      emails = [[current_case.email, current_case_role]] + current_case.additional_contacts_emails + sender_email
      emails.each do |email|
        # Extract the email part from @reply_form.to_recipients for comparison
        existing_emails = @reply_form.to_recipients.map { |recipient| recipient[0] }
        # Add the email only if it's not already in the list (ignoring roles)
        @reply_form.to_recipients << email unless existing_emails.include?(email[0])
      end
      if current_email.cc_recipients.present? && !@reply_form.cc_recipients.map { |recipient| recipient[0] }.include?(current_email.cc_recipients[0]["address"])
        sender_cc_recipients = current_email.cc_recipients.instance_of?(Array) ? current_email.cc_recipients.map { |recipient| [recipient["address"], [""]] } : current_email.cc_recipients[0]["address"] if current_email.cc_recipients.present?
        @reply_form.cc_recipients = Array(@reply_form.cc_recipients + sender_cc_recipients).to_json if sender_cc_recipients.present?
      end
      if current_email.bcc_recipients.present? && !@reply_form.bcc_recipients.map { |recipient| recipient[0] }.include?(current_email.bcc_recipients[0]["address"])
        sender_bcc_recipients = current_email.bcc_recipients.instance_of?(Array) ? current_email.bcc_recipients[0]["address"] : [[current_email.bcc_recipients[0]["address"], [""]]] if current_email.bcc_recipients.present?
        @reply_form.bcc_recipients = Array(@reply_form.bcc_recipients + sender_bcc_recipients).to_json if sender_bcc_recipients.present?
      end
      @reply_form.save_draft!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("recipient-frame",
                                                    partial: "support/cases/message_threads/recipient_table",
                                                    locals: { email: @reply_form })
        end
      end
    end

    def remove_recipient
      @reply_form = Email::Draft.find(params[:id])
      @sender_email = current_email.sender.instance_of?(Array) ? current_email.sender.map { |recipient| recipient["address"] } : [current_email.sender["address"]]
      recipient_to_remove = [params[:email], params[:role]]
      @reply_form.to_recipients.reject! { |recipient| recipient == recipient_to_remove }
      @reply_form.save_draft!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("recipient-frame",
                                                    partial: "support/cases/message_threads/recipient_table",
                                                    locals: { email: @reply_form })
        end
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

    def redirect_url
      return edit_support_case_message_reply_path(message_id: current_email.id, id: @draft.id) if params[:redirect_back].blank?

      url = URI.parse(url_for(params[:redirect_back]))
      query = URI.decode_www_form(url.query) << ["reply_frame_url", edit_support_case_message_reply_path(message_id: current_email.id, id: @draft.id)]
      url.query = URI.encode_www_form(query)
      url.to_s
    end

    def back_url
      @back_url = support_case_message_thread_path(id: @current_email.outlook_conversation_id, case_id: current_case.id)
    end
  end
end
