module Support
  module Management
    class SyncFrameworksController < BaseController
      after_action -> { flash.discard }, only: :create

      def index; end

      def create
        Support::SyncFrameworksJob.perform_later
        flash[:notice] = "Task triggered"
        render :index
      end
    end
  end
end
