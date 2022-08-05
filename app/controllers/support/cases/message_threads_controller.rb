module Support
  module Cases
    class MessageThreadsController < Cases::ApplicationController
      before_action :current_thread, only: %i[show]
      before_action :back_url, only: %i[index show]

      def index; end

      def show; end

    private

      def current_case
        @current_case ||= CasePresenter.new(Case.find_by(id: params[:case_id]))
      end

      def current_thread
        @current_thread ||= Support::MessageThread.find_by(conversation_id: params[:id])
      end

      def back_url
        @back_url ||= url_from(back_link_param) || support_cases_path
      end
    end
  end
end
