module Energy
  class MatSchoolPickerController < ApplicationController
    skip_before_action :check_if_submitted
    # before_action :form
    # before_action :case_request, only: %i[edit update]

    # GET /energy/which-mat-schools-buying-for/:uid
    def edit
      # energy_case = Energy::OnboardingCase.find(params[:energy_case_id])
      # @case_request = energy_case.support_case

      @back_url = energy_school_selection_path
      # @school_picker = form_params[:school_urns].nil? ? @case_request.school_picker : @case_request.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
      @group = Support::EstablishmentGroup.find_by(uid: params[:uid])
      @mat_schools = @group.organisations_for_multi_school_picker.order(:name)
      # @filters = @all_schools.filtering({ statuses: %w[opened opening closing] })
      # @filtered_schools = @filters.results.map { |s| Support::OrganisationPresenter.new(s) }
      # @all_selectable_schools = @filtered_schools
    end

    # POST /energy/which-mat-schools-buying-for/:uid
    def update
      # "mat_school_picker_form"=>{"mat_school_urn"=>"146856"}
      mat_school_urn = params[:mat_school_picker_form][:mat_school_urn]

      redirect_to school_type_energy_authorisation_path(id: mat_school_urn, type: "single")
    end

  private

    def form
      # @form ||= FrameworkRequests::SchoolPickerForm.new(all_form_params)
      @form ||= Energy::MatSchoolPickerForm.new
    end

    def case_request
      @case_request = CaseRequest.find_by(id: params[:id])
    end

    def form_params
      params.fetch(:case_request, {}).permit(filters: params.key?(:clear) ? nil : { local_authorities: [], phases: [], statuses: [] }, school_urns: [])
    end

    def all_form_params
      params.fetch(:framework_support_form, {}).permit(*%i[
        dsi
        school_type
        org_confirm
        special_requirements_choice
        source
      ], *form_params).merge(id: framework_request_id, user: current_user)
    end

    def framework_request_id
      return params[:id] if params[:id]
      return session[:framework_request_id] if session[:framework_request_id]

      session[:framework_request_id] = FrameworkRequest.create_with_inferred_attributes!(UserPresenter.new(current_user)).id
      session[:framework_request_id]
    end
  end
end
