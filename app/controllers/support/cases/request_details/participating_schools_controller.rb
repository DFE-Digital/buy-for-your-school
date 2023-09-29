module Support
  module Cases
    module RequestDetails
      class ParticipatingSchoolsController < Cases::ApplicationController
        def show
          @back_url = support_case_request_details_path
          @participating_schools = @current_case.request.selected_schools.map { |s| Support::OrganisationPresenter.new(s) }
        end
      end
    end
  end
end
