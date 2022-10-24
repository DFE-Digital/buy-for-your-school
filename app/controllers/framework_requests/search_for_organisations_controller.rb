module FrameworkRequests
  class SearchForOrganisationsController < BaseController
    skip_before_action :authenticate_user!

    def update
      if @form.valid?
        redirect_to update_redirect_path
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::SearchForOrganisationForm.new(all_form_params)
    end

    def form_params
      [:org_id]
    end

    def create_redirect_path
      confirm_organisation_framework_requests_path(framework_support_form: @form.common)
    end

    def update_redirect_path
      edit_framework_request_confirm_organisation_path(framework_support_form: validation.to_h)
    end

    def back_url
      @back_url = organisation_type_framework_requests_path(framework_support_form: @form.common)
    end

    def step_description
      @form.group ? I18n.t("faf.search_for_a_group.heading") : I18n.t("faf.search_for_a_school.heading")
    end
  end
end
