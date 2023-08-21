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
      if form.eligible_for_school_picker?
        school_picker_framework_requests_path(framework_support_form: form.common)
      elsif form.allow_bill_upload?
        bill_uploads_framework_requests_path(framework_support_form: form.common)
      else
        message_framework_requests_path(framework_support_form: form.common)
      end
    end

    def back_url
      @back_url = last_energy_path
    end
  end
end
