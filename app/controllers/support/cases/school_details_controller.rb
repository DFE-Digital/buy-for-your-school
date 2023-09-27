module Support
  module Cases
    class SchoolDetailsController < Cases::ApplicationController
    private

      def current_case
        @current_case ||= CasePresenter.new(super)
      end
    end
  end
end
