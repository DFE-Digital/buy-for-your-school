module FrameworkRequests
  class SelectOrganisationsController < BaseController
  private

    def form
      @form ||= FrameworkRequests::SelectOrganisationForm.new(all_form_params)
    end

    def form_params
      %i[org_id group]
    end

    def create_redirect_path
      return bill_uploads_framework_requests_path(framework_support_form: form.common) if form.allow_bill_upload?

      message_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = last_energy_path
    end
  end
end
