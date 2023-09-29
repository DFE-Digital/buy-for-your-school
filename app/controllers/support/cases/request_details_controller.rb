module Support
  module Cases
    class RequestDetailsController < Cases::ApplicationController
      def show
        @request = FrameworkRequestPresenter.new(@current_case.request)
      end

    private

      def current_case
        @current_case ||= CasePresenter.new(super)
      end
    end
  end
end
