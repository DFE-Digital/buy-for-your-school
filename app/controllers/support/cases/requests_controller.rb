module Support
  module Cases
    class RequestsController < Cases::ApplicationController
      def show
        @request = @current_case.framework_request
      end

    private

      def current_case
        @current_case ||= CasePresenter.new(super)
      end
    end
  end
end
