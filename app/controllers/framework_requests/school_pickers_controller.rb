module FrameworkRequests
  class SchoolPickersController < BaseController
    skip_before_action :authenticate_user!

    before_action :group
    before_action :all_schools
    before_action :all_selectable_schools
    before_action :filtered_schools
    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        redirect_to update_redirect_path
      else
        render :edit
      end
    end

  private

    def create_redirect_path
      confirm_schools_framework_requests_path(framework_support_form: form.common)
    end

    def update_redirect_path
      edit_framework_request_confirm_schools_path(framework_support_form: form.common)
    end

    def group
      @group ||= framework_request.organisation
    end

    def all_schools
      @all_schools = framework_request.available_schools
    end

    def all_selectable_schools
      @all_selectable_schools = filtered_schools
    end

    def filtered_schools
      @filtered_schools = @form.filters.results.map { |s| Support::OrganisationPresenter.new(s) }
    end

    def form
      @form ||= FrameworkRequests::SchoolPickerForm.new(all_form_params)
    end

    def form_params
      [school_urns: [], filters: params.key?(:clear) ? nil : { local_authorities: [], phases: [] }]
    end

    def back_url
      @current_user = UserPresenter.new(current_user)
      @back_url =
        if @current_user.guest?
          confirm_organisation_framework_requests_path(framework_support_form: form.common.merge(school_type: "group", org_confirm: true))
        elsif @current_user.single_org?
          confirm_sign_in_framework_requests_path(framework_support_form: form.common)
        else
          select_organisation_framework_requests_path(framework_support_form: form.common)
        end
    end

    def edit_back_url
      @back_url =
        if @form.source.change_link?
          framework_request_path
        else
          edit_framework_request_confirm_organisation_path(framework_support_form: @form.common.merge(school_type: "group", org_confirm: true))
        end
    end
  end
end
