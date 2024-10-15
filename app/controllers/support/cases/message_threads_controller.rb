module Support
  module Cases
    class MessageThreadsController < Cases::ApplicationController
      before_action :redirect_to_messages_tab, unless: :turbo_frame_request?, only: %i[show templated_messages logged_contacts]
      before_action :current_thread, only: %i[show]
      before_action :back_url, only: %i[index show edit submit templated_messages logged_contacts]

      helper_method :back_to_url_b64

      content_security_policy do |policy|
        policy.style_src_attr :unsafe_inline
      end

      def index
        @message_threads = @current_case.message_threads
        @templated_messages = @current_case.templated_messages
        @logged_contacts = @current_case.logged_contacts
      end

      def show
        reply_form
        @subject = @current_thread.subject
        @messages = @current_thread.messages
        @last_received_reply = @current_thread.last_received_reply
        set_reply_frame_url
      end

      def new
        @to_recipients = Array(current_case.email + @current_case.additional_contacts.pluck(:email)).to_json
      end

      def edit
        @reply_form = Email::Draft.find(params[:id])
      end

      def create
        contact_email = [[current_case.email, current_case.is_evaluator ? "Lead, Evaluator" : "Lead"]] if current_case.email.present?
        emails = Array(contact_email + current_case.additional_contacts_emails)
        draft = Email::Draft.new(
          default_content: default_template,
          default_subject:,
          template_id: params[:template_id],
          ticket: current_case.to_model,
          to_recipients: emails.to_json,
        ).save_draft!

        redirect_to edit_support_case_message_thread_path(id: draft.id)
      end

      def submit
        @reply_form = Email::Draft.find(params[:id])
        @reply_form.attributes = new_thread_params
        emails = @reply_form.to_recipients.map(&:first)
        @reply_form.to_recipients = emails.to_json
        @reply_form.cc_recipients = @reply_form.cc_recipients.map(&:first).to_json if @reply_form.cc_recipients.present?
        @reply_form.bcc_recipients = @reply_form.bcc_recipients.map(&:first).to_json if @reply_form.bcc_recipients.present?
        if @reply_form.valid?(:new_message)
          @reply_form.save_draft!
          @reply_form.deliver_as_new_message
          redirect_to support_case_message_threads_path(case_id: current_case.id)
        else
          render :edit
        end
      end

      def templated_messages; end

      def logged_contacts; end

      def back_to_url_b64
        return Base64.encode64(edit_support_case_message_thread_path(case_id: current_case.id, id: params[:id])) if action_name == "submit"

        current_url_b64
      end

    private

      def current_case
        @current_case ||= CasePresenter.new(super)
      end

      def current_thread
        @current_thread ||= Support::MessageThreadPresenter.new(Support::MessageThread.find_by(conversation_id: params[:id]))
      end

      def reply_form
        @reply_form = Email::Draft.new(
          default_content: default_template,
          default_subject:,
          template_id: params[:template_id],
          ticket: current_case,
        )
      end

      def back_url
        @back_url ||= url_from(back_link_param) || support_cases_path
      end

      def default_subject = "Case #{current_case.ref} – DfE Get help buying for schools: your request for advice and guidance"

      def default_template = render_to_string(partial: "support/cases/messages/reply_form_template")

      def redirect_to_messages_tab
        redirect_to support_case_path(id: params[:case_id], anchor: "messages", messages_tab_url: request.url)
      end

      def new_thread_params
        params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id)
      end

      def set_reply_frame_url
        return if params[:reply_frame_url].blank?

        url = Addressable::URI.parse(url_for(params[:reply_frame_url]))
        url.query_values = (url.query_values || {}).merge({
          template_id: params[:template_id],
        })
        @reply_frame_url = url.to_s
      end
    end
  end
end
