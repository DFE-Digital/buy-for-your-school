module FrameworkRequests
  class SpecialRequirementsController < BaseController
    skip_before_action :authenticate_user!

    def edit
      super
      @form.special_requirements_choice = framework_request.special_requirements == "-" ? "no" : "yes"
    end

  private

    def form
      @form ||= FrameworkRequests::SpecialRequirementsForm.new(all_form_params)
    end

    def form_params
      [:special_requirements]
    end

    def create_redirect_path
      origin_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = determine_back_path
    end

    def determine_back_path
      if framework_request.energy_category?
        if framework_request.has_bills?
          bill_uploads_framework_requests_path(framework_support_form: form.common)
        else
          energy_alternative_framework_requests_path(framework_support_form: form.common)
        end
      elsif flow.services? || flow.energy?
        if framework_request.has_documents?
          document_uploads_framework_requests_path(framework_support_form: form.common)
        else
          documents_framework_requests_path(framework_support_form: form.common)
        end
      else
        message_framework_requests_path(framework_support_form: form.common)
      end
    end
  end
end
