module Support
  module Cases
    class MessageThreadsController < Cases::ApplicationController
      before_action :redirect_to_messages_tab, unless: :turbo_frame_request?, only: %i[show templated_messages logged_contacts]
      before_action :current_thread, only: %i[show]
      before_action :reply_form, only: %i[new]
      before_action :back_url, only: %i[index show new templated_messages logged_contacts]

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
        @to_recipients = Array(current_case.email).to_json
      end

      def templated_messages; end

      def logged_contacts; end

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
