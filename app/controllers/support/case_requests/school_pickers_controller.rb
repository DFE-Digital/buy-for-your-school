module Support
  module CaseRequests
    class SchoolPickersController < ApplicationController
      before_action :case_request, only: %i[edit update]

      def edit
        @back_url = params[:source] == "change_link" ? support_case_request_path(@case_request) : edit_support_case_request_path(@case_request)
        @school_picker = form_params[:school_urns].nil? ? @case_request.school_picker : @case_request.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
        @group = @case_request.organisation
        @all_schools = @group.organisations_for_multi_school_picker.order(:name)
        @filters = @all_schools.filtering(form_params[:filters] || {})
        @filtered_schools = @filters.results.map { |s| Support::OrganisationPresenter.new(s) }
        @all_selectable_schools = @filtered_schools
      end

      def update
        @school_picker = @case_request.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
        @school_picker.save!
        redirect_to support_case_request_path(@case_request)
      end

    private

      def case_request
        @case_request = CaseRequest.find_by(id: params[:id])
      end

      def form_params
        params.fetch(:case_request, {}).permit(filters: params.key?(:clear) ? nil : { local_authorities: [], phases: [] }, school_urns: [])
      end
    end
  end
end
