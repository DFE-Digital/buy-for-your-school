module FrameworkRequests
  class NamesController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::NameForm.new(all_form_params)
    end

    def form_params
      %i[first_name last_name]
    end

    def update_data
      { first_name: @form.first_name, last_name: @form.last_name }
    end

    def create_redirect_path
      email_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = framework_request.school_urns.present? ? confirm_schools_framework_requests_path(framework_support_form: form.common) : confirm_organisation_framework_requests_path(framework_support_form: form.common)
    end
  end
end
