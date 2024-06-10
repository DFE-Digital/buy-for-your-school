module Support
  module Cases
    module SchoolDetails
      class ParticipatingSchoolsController < Cases::ApplicationController
        def show
          @back_url = support_case_school_details_path
          @participating_schools = @current_case.participating_schools.includes([:local_authority]).order(:name).map { |s| Support::OrganisationPresenter.new(s) }
        end

        def edit
          @back_url = support_case_school_details_participating_schools_path
          @case_school_picker = form_params[:school_urns].nil? ? current_case.school_picker : current_case.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
          @group = current_case.organisation
          @all_schools = @group.organisations_for_multi_school_picker.order(:name)
          @all_selectable_schools = @all_schools.map { |s| Support::OrganisationPresenter.new(s) }
          @filters = @all_schools.filtering(form_params[:filters] || {})
          @filtered_schools = @filters.results.map { |s| Support::OrganisationPresenter.new(s) }
        end

        def update
          @case_school_picker = current_case.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
          @case_school_picker.save!
          redirect_to support_case_school_details_participating_schools_path
        end

      private

        def form_params
          params.fetch(:participating_schools, {}).permit(filters: params.key?(:clear) ? nil : { local_authorities: [], phases: [] }, school_urns: [])
        end
      end
    end
  end
end
