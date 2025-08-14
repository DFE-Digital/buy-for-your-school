module Energy
  class MatSchoolPickerController < ApplicationController
    skip_before_action :check_if_submitted
    before_action :form
    before_action :case_request, only: %i[edit update]

    def edit
      # Create the support case
      @case_request = Energy::CaseCreatable.create_case(current_user)

      @back_url = energy_school_selection_path
      @school_picker = form_params[:school_urns].nil? ? @case_request.school_picker : @case_request.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
      @group = Support::EstablishmentGroup.find_by(uid: params[:id])
      @all_schools = @group.organisations_for_multi_school_picker.order(:name)
      @filters = @all_schools.filtering({ statuses: %w[opened opening closing] })
      @filtered_schools = @filters.results.map { |s| Support::OrganisationPresenter.new(s) }
      @all_selectable_schools = @filtered_schools
    end

    def update
      @school_picker = @case_request.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
      @school_picker.save!
      if @case_request.school_urns.count < 2 && @case_request.is_energy_or_services?
        redirect_to edit_engagement_case_request_contract_start_date_path(@case_request)
      elsif @case_request.school_urns.count > 1
        redirect_to edit_engagement_case_request_same_supplier_path(@case_request)
      else
        redirect_to engagement_case_request_path(@case_request)
      end
    end

  private
    def form
      @form ||= FrameworkRequests::SchoolPickerForm.new #(all_form_params)
    end

    def case_request
      @case_request = CaseRequest.find_by(id: params[:id])
    end

    def form_params
      params.fetch(:case_request, {}).permit(filters: params.key?(:clear) ? nil : { local_authorities: [], phases: [], statuses: [] }, school_urns: [])
    end
  end
end

