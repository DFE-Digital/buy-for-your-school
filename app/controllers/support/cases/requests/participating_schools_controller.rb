module Support
  module Cases
    module Requests
      class ParticipatingSchoolsController < Cases::ApplicationController
        def show
          @back_url = support_case_request_path
          @participating_schools = @current_case.framework_request.selected_schools.map { |s| Support::OrganisationPresenter.new(s) }
        end
      end
    end
  end
end
