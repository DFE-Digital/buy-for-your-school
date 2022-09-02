module Support
  module Cases
    class MessageThreadsController < Cases::ApplicationController
      before_action :current_thread, only: %i[show]
      before_action :reply_form, only: %i[index show new]
      before_action :back_url, only: %i[index show new templated_messages logged_contacts]
      before_action :default_subject_line, only: %i[new]

      content_security_policy do |policy|
        policy.style_src_attr :unsafe_inline
      end

      def index; end

      def show; end

      def new; end

      def templated_messages; end

      def logged_contacts; end

    private

      def current_case
        @current_case ||= CasePresenter.new(Case.find_by(id: params[:case_id]))
      end

      def current_thread
        @current_thread ||= Support::MessageThreadPresenter.new(Support::MessageThread.find_by(conversation_id: params[:id]))
      end

      def reply_form
        @reply_form = Support::Messages::ReplyForm.new
      end

      def back_url
        @back_url ||= url_from(back_link_param) || support_cases_path
      end

      def default_subject_line
        @default_subject_line ||= "Case #{current_case.ref} – DfE Get help buying for schools: your request for advice and guidance"
      end
    end
  end
end
