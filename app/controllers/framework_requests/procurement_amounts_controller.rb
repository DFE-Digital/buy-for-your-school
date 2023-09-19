module FrameworkRequests
  class ProcurementAmountsController < BaseController
    skip_before_action :authenticate_user!

  private

    def form
      @form ||= FrameworkRequests::ProcurementAmountForm.new(all_form_params)
    end

    def form_params
      [:procurement_amount]
    end

    def create_redirect_path
      message_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url =
        if flow.energy? || flow.services?
          if framework_request.multischool_with_multiple_selections?
            same_supplier_framework_requests_path(framework_support_form: @form.common)
          else
            contract_start_date_framework_requests_path(framework_support_form: @form.common)
          end
        else
          categories_framework_requests_path(category_path: framework_request.category&.ancestors_slug, framework_support_form: @form.common)
        end
    end
  end
end
