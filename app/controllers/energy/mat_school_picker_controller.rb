module Energy
  class MatSchoolPickerController < ApplicationController
    skip_before_action :check_if_submitted
    before_action :form
    before_action :case_request, only: %i[edit update]

    # GET /energy/which-mat-schools-buying-for/:energy_case_id/:mat_uid
    def edit
      energy_case = Energy::OnboardingCase.find(params[:energy_case_id])
      @case_request = energy_case.support_case

      @back_url = energy_school_selection_path
      @school_picker = form_params[:school_urns].nil? ? @case_request.school_picker : @case_request.school_picker(school_urns: form_params[:school_urns].compact_blank.excluding("all"))
      @group = Support::EstablishmentGroup.find_by(uid: params[:mat_uid])
      @all_schools = @group.organisations_for_multi_school_picker.order(:name)
      @filters = @all_schools.filtering({ statuses: %w[opened opening closing] })
      @filtered_schools = @filters.results.map { |s| Support::OrganisationPresenter.new(s) }
      @all_selectable_schools = @filtered_schools
    end

    # POST /energy/which-mat-schools-buying-for/:energy_case_id/:mat_uid
    def update
      mat_school_urn = params[:framework_support_form][:school_urns].reject(&:empty?).first
      mat_school = Support::Organisation.find_by(urn: mat_school_urn)

      # Create the Energy org
      onboarding_case = Energy::OnboardingCase.find(params[:energy_case_id])
      Energy::OnboardingCaseOrganisation.create!(onboardable: mat_school, onboarding_case:)

      redirect_to school_type_energy_authorisation_path(id: params[:mat_uid],
                                                        type: "mat",
                                                        onboarding_case_id: onboarding_case.id)
    end

  private

    def form
      @form ||= FrameworkRequests::SchoolPickerForm.new(all_form_params)
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
