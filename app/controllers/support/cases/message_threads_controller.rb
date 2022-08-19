module Support
  module Cases
    class MessageThreadsController < Cases::ApplicationController
      before_action :current_thread, only: %i[show]
      before_action :reply_form, only: %i[index show]
      before_action :back_url, only: %i[index show templated_messages logged_contacts]

      content_security_policy do |policy|
        policy.style_src_attr :unsafe_inline
      end

      def index; end

      def show; end

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
    end
  end
end
