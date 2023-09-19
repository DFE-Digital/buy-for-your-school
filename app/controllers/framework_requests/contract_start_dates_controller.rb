module FrameworkRequests
  class ContractStartDatesController < BaseController
    include Support::Concerns::HasDateParams

    skip_before_action :authenticate_user!

    before_action :edit_back_url, only: %i[update]

    def update
      if @form.valid?
        @form.save!
        if flow.unfinished?
          if framework_request.multischool_with_multiple_selections?
            redirect_to edit_framework_request_same_supplier_path(framework_request)
          else
            redirect_to framework_request.energy_category? ? edit_framework_request_energy_bill_path(framework_request) : edit_framework_request_documents_path(framework_request)
          end
        else
          redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
        end
      else
        render :edit
      end
    end

  private

    def form
      @form ||= FrameworkRequests::ContractStartDateForm.new(all_form_params)
    end

    def form_params
      %i[contract_start_date_known contract_start_date]
    end

    def all_form_params
      super
        .except("contract_start_date(3i)", "contract_start_date(2i)", "contract_start_date(1i)")
        .merge(contract_start_date: date_param(:framework_support_form, :contract_start_date).compact_blank)
    end

    def create_redirect_path
      if framework_request.multischool_with_multiple_selections?
        same_supplier_framework_requests_path(framework_support_form: form.common)
      else
        procurement_amount_framework_requests_path(framework_support_form: form.common)
      end
    end

    def back_url
      @back_url = contract_length_framework_requests_path(ramework_support_form: @form.common)
    end

    def edit_back_url
      @back_url =
        if flow.unfinished?
          edit_framework_request_contract_length_path(framework_support_form: form.common)
        else
          framework_request_path(form.framework_request)
        end
    end
  end
end
