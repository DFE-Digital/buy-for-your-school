module FrameworkRequests
  class SameSuppliersController < BaseController
    skip_before_action :authenticate_user!

    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        @form.save!
        if flow.unfinished?
          redirect_to framework_request.energy_category? ? edit_framework_request_energy_bill_path(framework_request) : edit_framework_request_documents_path(framework_request)
        else
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::SameSupplierForm.new(all_form_params)
    end

    def form_params
      [:same_supplier_used]
    end

    def create_redirect_path
      procurement_amount_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = contract_start_date_framework_requests_path(framework_support_form: @form.common)
    end

    def edit_back_url
      @back_url =
        if @form.source.change_link?
          framework_request_path
        elsif flow.unfinished?
          edit_framework_request_contract_start_date_path(framework_request)
        else
          edit_framework_request_confirm_schools_path(framework_request)
        end
    end
  end
end
